
class UserProfileData {
  final String? gender;
  final String? dateOfBirth;
  final double? weight; // Changed to double?
  final int? height;   // Changed to int?
  // You can add more fields here as you expand the profile

  UserProfileData({
    this.gender,
    this.dateOfBirth,
    this.weight,
    this.height,
  });

  // Method to convert the object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'weight': weight, // Will now store as double
      'height': height, // Will now store as int
      // Add other fields here
    };
  }

  // Factory method to create a UserProfileData object from a Firestore Map (for reading later)
  factory UserProfileData.fromMap(Map<String, dynamic> data) {
    return UserProfileData(
      gender: data['gender'] as String?,
      dateOfBirth: data['dateOfBirth'] as String?,
      // Read as double?
      weight: (data['weight'] is num) ? (data['weight'] as num).toDouble() : null, // Handle potential null or wrong type
      // Read as int?
      height: (data['height'] is num) ? (data['height'] as num).toInt() : null, // Handle potential null or wrong type
      // Map other fields here
    );
  }
}
