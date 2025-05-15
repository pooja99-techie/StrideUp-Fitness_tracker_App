// lib/services/user_profile_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_data.dart'; // Import the updated data model

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to save user profile data to Firestore
  Future<void> saveProfileData({
    required String userId,
    required UserProfileData profileData, // profileData now contains double and int
  }) async {
    try {
      // Get a reference to the specific user's document in the 'users' collection
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);

      // Get the data as a Map from the UserProfileData object
      // toMap() method will now produce a Map with double and int values
      Map<String, dynamic> dataToSave = profileData.toMap();

      // Add server timestamps for created/updated time
      // We only add these if they are not already present, or if we specifically want to update them.
      // For this "complete profile" screen, adding them on creation/update makes sense.
      if (!dataToSave.containsKey('createdAt')) {
        dataToSave['createdAt'] = FieldValue.serverTimestamp();
      }
      dataToSave['updatedAt'] = FieldValue.serverTimestamp();


      // Use .set() to write the data to the document.
      // SetOptions(merge: true) ensures that if the document already exists
      // (e.g., user came back to edit profile), it updates these fields
      // without deleting any other existing data in the document.
      await userDocRef.set(dataToSave, SetOptions(merge: true));

      print("Profile data saved successfully for user: $userId");

    } on FirebaseException catch (e) {
      print("Firebase Error saving profile data via service: ${e.code} - ${e.message}");
      // Rethrow the exception so the UI layer can handle it (e.g., show SnackBar)
      rethrow;
    } catch (e) {
      print("Error saving profile data via service: $e");
      // Rethrow other exceptions as well
      rethrow;
    }
  }

  // Optional: Add a method to read profile data (useful for ProfileView)
  Future<UserProfileData?> getProfileData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        // Use the fromMap factory method to create the object
        // This factory method now handles reading double and int types
        return UserProfileData.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("Profile document does not exist for user: $userId");
        return null; // Return null if the document or data doesn't exist
      }
    } on FirebaseException catch (e) {
      print("Firebase Error reading profile data via service: ${e.code} - ${e.message}");
      rethrow; // Rethrow for UI handling
    } catch (e) {
      print("Error reading profile data via service: $e");
      rethrow; // Rethrow other exceptions
    }
  }
}
