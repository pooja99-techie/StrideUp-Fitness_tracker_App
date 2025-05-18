import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/water_intake_event.dart'; // Add intl dependency for date formatting if needed


class WaterIntakeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get the current user's document reference
  DocumentReference? _currentUserDocRef() {
    final user = _auth.currentUser;
    if (user == null) {
      print("Error: User not logged in.");
      return null;
    }
    return _firestore.collection('users').doc(user.uid);
  }

  // Helper to get a specific date string in YYYY-MM-DD format
  String _getDateString(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Helper to get today's date string
  String _getTodayDateString() {
    return _getDateString(DateTime.now());
  }


  // --- Add a Water Intake Event ---
  // This method will also update the 'waterAchieved' field in the daily target document
  Future<void> addWaterIntakeEvent({required int amount}) async {
    final userDocRef = _currentUserDocRef();
    if (userDocRef == null) {
      throw Exception("User not logged in. Cannot add water intake.");
    }

    final todayDate = _getTodayDateString();
    final dailyTargetDocRef = userDocRef.collection('dailyTargets').doc(todayDate);
    final waterIntakeCollectionRef = dailyTargetDocRef.collection('waterIntakeEvents');

    try {
      // 1. Add the specific intake event
      await waterIntakeCollectionRef.add({
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(), // Use server timestamp
      });

      // 2. Increment the total 'waterAchieved' in the daily target document
      await dailyTargetDocRef.set({
        'waterAchieved': FieldValue.increment(amount),
        // Optionally add/update a timestamp for the last achieved update
        'lastAchievedUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge: true so we don't overwrite targets if they exist

      print("Water intake event added and daily total incremented for $todayDate!");

    } catch (e) {
      print("Error adding water intake event: $e");
      // Rethrow the error for the UI to handle
      throw e;
    }
  }

  // --- Get Stream of Today's Water Intake Events ---
  // This provides real-time updates for the list of recent entries
  Stream<List<WaterIntakeEvent>> getTodayWaterIntakeEventsStream() {
    final userDocRef = _currentUserDocRef();
    if (userDocRef == null) {
      // Return an empty stream or throw an error if user is not logged in
      // For a stream, returning an empty stream is often cleaner
      print("User not logged in. Returning empty stream for water intake events.");
      return Stream.value([]); // Returns a stream that immediately emits an empty list
    }

    final todayDate = _getTodayDateString();
    // Note: Use .orderBy('timestamp', descending: true) if you want latest first in the list
    return userDocRef
        .collection('dailyTargets')
        .doc(todayDate)
        .collection('waterIntakeEvents')
        .orderBy('timestamp', descending: true) // Order by time, latest first
        .snapshots() // Get the stream of snapshots
        .map((snapshot) {
      // Map the QuerySnapshot to a list of WaterIntakeEvent objects
      return snapshot.docs.map((doc) => WaterIntakeEvent.fromDocument(doc)).toList();
    })
        .handleError((e) {
      print("Error fetching today's water intake events stream: $e");
      // Depending on desired error handling, you might throw, log, or return empty list
      throw e; // Rethrow the error
    });
  }

  // --- Get Stream of Today's Total Water Intake ---
  // This provides real-time updates for the achieved total number
  Stream<int> getTodayTotalWaterIntakeStream() {
    final userDocRef = _currentUserDocRef();
    if (userDocRef == null) {
      print("User not logged in. Returning stream with 0 for total water intake.");
      return Stream.value(0); // Emit 0 if user is not logged in
    }

    final todayDate = _getTodayDateString();
    final dailyTargetDocRef = userDocRef.collection('dailyTargets').doc(todayDate);

    return dailyTargetDocRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        // Get the waterAchieved field, default to 0 if not exists or null
        return (data?['waterAchieved'] as num?)?.toInt() ?? 0; // num handles both int/double from Firestore
      } else {
        // Document doesn't exist yet for today (no targets set or water logged)
        return 0;
      }
    })
        .handleError((e) {
      print("Error fetching today's total water intake stream: $e");
      // Depending on desired error handling, you might throw, log, or return 0
      throw e; // Rethrow the error
    });
  }


  // --- Get Historical Daily Totals ---
  // Fetches the waterAchieved total for a range of past days.
  // This is suitable for displaying on a graph showing progress over time.
  // We assume the 'waterAchieved' field in the daily target document is maintained.
  Future<Map<String, int>> getHistoricalDailyTotals({int numberOfDays = 7}) async {
    final userDocRef = _currentUserDocRef();
    if (userDocRef == null) {
      print("User not logged in. Cannot load historical data.");
      return {}; // Return empty map if user is not logged in
    }

    Map<String, int> dailyTotals = {};
    final now = DateTime.now();

    try {
      // We need to fetch documents for each of the last `numberOfDays`.
      // Firestore doesn't have a direct "fetch documents for these N dates" query across a date range *in a subcollection*.
      // We have to query each day's document specifically.

      // Prepare a list of dates (YYYY-MM-DD strings) for the last N days
      List<String> datesToFetch = [];
      for (int i = 0; i < numberOfDays; i++) {
        final date = now.subtract(Duration(days: i));
        datesToFetch.add(_getDateString(date));
      }

      // Fetch each document individually (can be made more efficient with Future.wait)
      await Future.wait(datesToFetch.map((dateString) async {
        final docSnapshot = await userDocRef.collection('dailyTargets').doc(dateString).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>?;
          final total = (data?['waterAchieved'] as num?)?.toInt() ?? 0;
          dailyTotals[dateString] = total; // Store total using date string as key
        } else {
          dailyTotals[dateString] = 0; // 0 if no data for that day
        }
      }));

      print("Loaded historical daily water intake totals for the last $numberOfDays days.");
      return dailyTotals;

    } catch (e) {
      print("Error loading historical daily water intake totals: $e");
      // Rethrow or return empty map based on desired error handling
      throw e;
    }
  }

// --- Optional: Update Water Achieved Manually ---
// You might need this if you allow users to manually adjust the achieved total
// or if you calculate it differently. In our case, addWaterIntakeEvent handles increments.
/*
   Future<void> updateDailyWaterAchieved(int totalAchieved) async {
      final userDocRef = _currentUserDocRef();
       if (userDocRef == null) {
         throw Exception("User not logged in. Cannot update total.");
       }

       final todayDate = _getTodayDateString();
       final dailyTargetDocRef = userDocRef.collection('dailyTargets').doc(todayDate);

       try {
          await dailyTargetDocRef.set({
             'waterAchieved': totalAchieved,
             'lastAchievedUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

           print("Daily total water intake updated to $totalAchieved for $todayDate!");

       } catch (e) {
           print("Error updating daily total water intake: $e");
           throw e;
       }
   }
   */

// --- Optional: Get Daily Target Stream ---
// You might also want a stream for the daily target itself in case it's updated
/*
    Stream<int> getTodayWaterTargetStream() {
       final userDocRef = _currentUserDocRef();
        if (userDocRef == null) {
          return Stream.value(8000); // Default if user not logged in
        }

        final todayDate = _getTodayDateString();
        final dailyTargetDocRef = userDocRef.collection('dailyTargets').doc(todayDate);

        return dailyTargetDocRef.snapshots().map((snapshot) {
           if (snapshot.exists) {
              final data = snapshot.data() as Map<String, dynamic>?;
              return (data?['waterTarget'] as num?)?.toInt() ?? 8000; // Default target if not set
           } else {
              return 8000; // Default if no document for today
           }
        })
        .handleError((e) {
            print("Error fetching today's water target stream: $e");
            throw e;
         });
    }
   */
}
