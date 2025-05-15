import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strideup_fitness_app/common_widget/round_button.dart'; // Assuming you want a round button for Save
import 'package:strideup_fitness_app/common/colo_extension.dart'; // Assuming you need your color definitions

class EditProfileView extends StatefulWidget {
  // We might pass initial data here later, but let's fetch it inside for now
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  // Controllers for the text fields
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController(); // For date of birth input

  bool _isLoading = true; // To show a loading indicator while fetching data

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load existing data when the screen initializes
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _heightController.dispose();
    _weightController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle case where user is not logged in
      print("No user logged in to edit profile.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        // Populate controllers with existing data, handle nulls gracefully
        _heightController.text = data['height']?.toString() ?? '';
        _weightController.text = data['weight']?.toString() ?? '';
        _dateOfBirthController.text = data['dateOfBirth']?.toString() ?? ''; // Populate date of birth

      } else {
        print("User document not found for pre-populating edit fields.");
        // Controllers will remain empty, user can input new data
      }
    } catch (e) {
      print("Error loading user data for editing: $e");
      // Controllers will remain empty or show previous value on hot reload
    } finally {
      setState(() {
        _isLoading = false; // Stop loading regardless of success/failure
      });
    }
  }


  Future<void> _saveUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle case where user is not logged in
      print("No user logged in to save profile.");
      return;
    }

    // Get data from controllers
    final String height = _heightController.text.trim();
    final String weight = _weightController.text.trim();
    final String dateOfBirth = _dateOfBirthController.text.trim();

    // Basic validation (optional but recommended)
    if (height.isEmpty && weight.isEmpty && dateOfBirth.isEmpty) {
      print("No data to save."); // Or show a message to the user
      return;
    }

    // Prepare data for update - Only include fields that have values
    Map<String, dynamic> updateData = {};
    if (height.isNotEmpty) {
      // You might want to parse to a number type here if height is stored as a number
      // For simplicity, saving as string for now.
      updateData['height'] = height;
    }
    if (weight.isNotEmpty) {
      // You might want to parse to a number type here if weight is stored as a number
      // For simplicity, saving as string for now.
      updateData['weight'] = weight;
    }
    if (dateOfBirth.isNotEmpty) {
      updateData['dateOfBirth'] = dateOfBirth;
    }

    // No need to update if no fields have valid values to update
    if (updateData.isEmpty) {
      print("No valid data to save.");
      return;
    }


    try {
      // Update the document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update(updateData); // Use update to merge changes

      print("Profile data updated successfully!");
      // Optionally show a success message (e.g., SnackBar)

      // Navigate back to the ProfileView after saving
      Navigator.pop(context);

    } catch (e) {
      print("Error updating profile data: $e");
      // Optionally show an error message to the user
    }
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton( // Add a back button
          icon: Icon(Icons.arrow_back, color: TColor.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Height Input
            Text(
              "Height (cm)",
              style: TextStyle(color: TColor.gray, fontSize: 12),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number, // Suggest numeric input
              decoration: InputDecoration(
                hintText: "Enter Height",
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: TColor.lightGray)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: TColor.primaryColor1) // Assuming primaryColor1 is defined
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Weight Input
            Text(
              "Weight (kg)",
              style: TextStyle(color: TColor.gray, fontSize: 12),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number, // Suggest numeric input
              decoration: InputDecoration(
                hintText: "Enter Weight",
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: TColor.lightGray)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: TColor.primaryColor1)
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date of Birth Input (or you could calculate/input age)
            Text(
              "Date of Birth (MM/DD/YYYY)", // Adjust format based on your data
              style: TextStyle(color: TColor.gray, fontSize: 12),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _dateOfBirthController,
              keyboardType: TextInputType.datetime, // Suggest date input
              decoration: InputDecoration(
                hintText: "Enter Date of Birth",
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: TColor.lightGray)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: TColor.primaryColor1)
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            RoundButton(
              title: "Save Changes",
              type: RoundButtonType.bgGradient, // Assuming this gives a gradient button
              onPressed: _saveUserData, // Call the save function
            ),
          ],
        ),
      ),
    );
  }
}
