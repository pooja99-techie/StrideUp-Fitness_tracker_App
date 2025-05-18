import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Optional: You could define a simple data class for Daily Targets
// class DailyTarget {
//   final int waterTarget;
//   final int stepsTarget;
//   final int waterAchieved;
//   final int stepsAchieved;
//   final DateTime? lastUpdated; // Nullable as per Firestore timestamp

//   DailyTarget({
//     required this.waterTarget,
//     required this.stepsTarget,
//     this.waterAchieved = 0,
//     this.stepsAchieved = 0,
//     this.lastUpdated,
//   });

//   factory DailyTarget.fromMap(Map<String, dynamic> data) {
//     return DailyTarget(
//       waterTarget: data['waterTarget'] ?? 8000, // Use default if null
//       stepsTarget: data['stepsTarget'] ?? 2400, // Use default if null
//       waterAchieved: data['waterAchieved'] ?? 0,
//       stepsAchieved: data['stepsAchieved'] ?? 0,
//       lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'waterTarget': waterTarget,
//       'stepsTarget': stepsTarget,
//       'waterAchieved': waterAchieved,
//       'stepsAchieved': stepsAchieved,
//       // lastUpdated is often handled by FieldValue.serverTimestamp() on save
//     };
//   }
// }


class DailyTargetFirestoreService {
  // Get the current user's ID
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Get a reference to the user's daily targets collection
  CollectionReference? get _userDailyTargetsCollection {
    final userId = _currentUserId;
    if (userId == null) {
      print("Error: User not logged in.");
      return null; // Return null if user is not logged in
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('dailyTargets');
  }

  // Helper to get today's date string in YYYY-MM-DD format
  String _getTodayDateString() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  // --- Save Daily Targets ---
  Future<void> saveDailyTargets({required int waterTarget, required int stepsTarget}) async {
    final dailyTargetsCollection = _userDailyTargetsCollection;
    if (dailyTargetsCollection == null) {
      throw Exception("User not logged in. Cannot save targets.");
    }

    final todayDate = _getTodayDateString();
    final dailyTargetDocRef = dailyTargetsCollection.doc(todayDate);

    try {
      await dailyTargetDocRef.set({
        'waterTarget': waterTarget,
        'stepsTarget': stepsTarget,
        // Ensure these fields exist if saving targets for the first time
        'waterAchieved': FieldValue.increment(0),
        'stepsAchieved': FieldValue.increment(0),
        'lastUpdated': FieldValue.serverTimestamp(), // Optional: track when target was set
      }, SetOptions(merge: true)); // Use merge: true to only update the specified fields

      print("Daily targets saved to Firestore for $todayDate!");

    } catch (e) {
      print("Error saving daily targets: $e");
      // Rethrow the error or handle it as needed
      throw e;
    }
  }

  // --- Load Daily Targets ---
  // Returns a Map of targets or null if not found/user not logged in
  Future<Map<String, int>?> loadDailyTargets() async {
    final dailyTargetsCollection = _userDailyTargetsCollection;
    if (dailyTargetsCollection == null) {
      print("User not logged in. Cannot load targets.");
      return null; // Return null if user not logged in
    }

    final todayDate = _getTodayDateString();
    final dailyTargetDocRef = dailyTargetsCollection.doc(todayDate);

    try {
      final dailyTargetSnapshot = await dailyTargetDocRef.get();

      if (dailyTargetSnapshot.exists) {
        // Data found for today
        Map<String, dynamic> data = dailyTargetSnapshot.data() as Map<String, dynamic>;
        // Return a map containing the relevant target values
        return {
          'waterTarget': data['waterTarget'] ?? 8000, // Use default if null in Firestore
          'stepsTarget': data['stepsTarget'] ?? 2400, // Use default if null in Firestore
          'waterAchieved': data['waterAchieved'] ?? 0, // Include achieved for potential future use
          'stepsAchieved': data['stepsAchieved'] ?? 0, // Include achieved for potential future use
        };
      } else {
        // No data for today
        print("No daily targets found for $todayDate in Firestore.");
        return null; // Indicate that no data was found
      }

    } catch (e) {
      print("Error loading daily targets: $e");
      // Rethrow the error or return null depending on desired error handling
      throw e; // Rethrow for the UI to catch and display an error
    }
  }

// Note: You might add methods here later for updating achieved counts, etc.
}
