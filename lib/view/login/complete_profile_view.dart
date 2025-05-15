import 'package:flutter/material.dart';
import 'package:strideup_fitness_app/common/colo_extension.dart';
import 'package:strideup_fitness_app/view/login/what_your_goal_view.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';

// Import Firebase Authentication and Firestore
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// Import for date formatting
import 'package:intl/intl.dart';
// Assuming LoginView exists for potential redirects after errors or no user
import 'package:strideup_fitness_app/view/login/login_view.dart';

// Import the new service and data model files
import '../../services/user_profile_service.dart';
import '../../models/user_profile_data.dart';


class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  // Controllers for input fields
  TextEditingController txtDate = TextEditingController();
  TextEditingController txtWeight = TextEditingController();
  TextEditingController txtHeight = TextEditingController();

  // Variable for selected gender
  String? _selectedGender;

  // Instantiate the UserProfileService
  final UserProfileService _userProfileService = UserProfileService();


  // Dispose controllers when the widget is removed
  @override
  void dispose() {
    txtDate.dispose();
    txtWeight.dispose();
    txtHeight.dispose();
    super.dispose();
  }

  // Function to show the date picker and update the text field
  Future<void> _selectDateOfBirth(BuildContext context) async {
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 20));
    DateTime firstDate = DateTime.now().subtract(const Duration(days: 365 * 100));
    DateTime lastDate = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: TColor.primaryColor1,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: TColor.black,
            ),
            dialogTheme: const DialogTheme(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    // --- Add mounted check AFTER the await ---
    if (!mounted) return;

    if (pickedDate != null) {
      String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
      setState(() {
        txtDate.text = formattedDate;
      });
    }
  }

  // Function to save profile data to Firestore using the service
  Future<void> _saveProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("Error: No user is logged in to save profile data.");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in.')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
      return;
    }

    String userId = user.uid;

    String dateOfBirth = txtDate.text.trim();
    String weightString = txtWeight.text.trim(); // Get string value
    String heightString = txtHeight.text.trim(); // Get string value
    String gender = _selectedGender ?? "";

    // Basic validation for required fields
    if (_selectedGender == null || dateOfBirth.isEmpty || weightString.isEmpty || heightString.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Parse weight and height strings to numbers
    double? weightValue = double.tryParse(weightString);
    int? heightValue = int.tryParse(heightString);

    // Validate if parsing was successful
    if (weightValue == null || heightValue == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers for weight and height.')),
      );
      return;
    }

    try {
      // --- USE THE SERVICE TO SAVE DATA ---

      // 1. Create a UserProfileData object using the collected and PARSED data
      UserProfileData profileData = UserProfileData(
        gender: gender,
        dateOfBirth: dateOfBirth,
        weight: weightValue, // Pass the parsed double value
        height: heightValue, // Pass the parsed int value
      );

      // 2. Call the saveProfileData method on the service instance
      await _userProfileService.saveProfileData(
        userId: userId,
        profileData: profileData,
      );

      // --- SERVICE CALL COMPLETE ---


      print("Profile data saved successfully for user: $userId");

      // --- Add mounted check AFTER the await (service call) and BEFORE using context ---
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile data saved!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WhatYourGoalView(),
        ),
      );

    } on FirebaseException catch (e) {
      print("Firebase Error saving profile data: ${e.code} - ${e.message}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase Error saving profile data: ${e.message}')),
      );
    } catch (e) {
      print("Error saving profile data: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile data: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Image.asset(
                  "assets/img/complete_profile.png",
                  width: media.width,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Text(
                  "Let’s complete your profile",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  "It will help us to know more about you!",
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: TColor.lightGray,
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            Container(
                                alignment: Alignment.center,
                                width: 50,
                                height: 50,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 15),
                                child: Image.asset(
                                  "assets/img/gender.png",
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  color: TColor.gray,
                                )),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>( // Specify the type for clarity
                                  value: _selectedGender, // Link value to our state variable
                                  items: ["Male", "Female"]
                                      .map((name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          color: TColor.gray,
                                          fontSize: 14),
                                    ),
                                  ))
                                      .toList(),
                                  onChanged: (String? newValue) { // Use nullable String for newValue
                                    setState(() {
                                      _selectedGender = newValue; // Update the state
                                    });
                                  },
                                  isExpanded: true,
                                  hint: Text(
                                    "Choose Gender",
                                    style: TextStyle(
                                        color: TColor.gray, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),

                      // Wrap the RoundTextField for Date of Birth in GestureDetector and AbsorbPointer
                      GestureDetector(
                        onTap: () => _selectDateOfBirth(context), // Call the date picker function on tap
                        child: AbsorbPointer( // AbsorbPointer prevents the keyboard from showing for the TextField
                          child: RoundTextField(
                            controller: txtDate,
                            hitText: "Date of Birth",
                            icon: "assets/img/date.png",
                            // readOnly parameter is not part of your RoundTextField,
                            // using AbsorbPointer and GestureDetector instead
                            // keyboardType: TextInputType.datetime, // Removed as it's now handled by date picker
                          ),
                        ),
                      ),

                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              controller: txtWeight, // Use the new weight controller
                              hitText: "Your Weight",
                              icon: "assets/img/weight.png",
                              keyboardType: TextInputType.numberWithOptions(decimal: true), // Numeric input for weight
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.secondaryG,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "KG",
                              style:
                              TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              controller: txtHeight, // Use the new height controller
                              hitText: "Your Height",
                              icon: "assets/img/hight.png",
                              keyboardType: TextInputType.number, // Integer input for height in CM
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.secondaryG,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "CM",
                              style:
                              TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.07,
                      ),
                      RoundButton(
                          title: "Next >",
                          onPressed:
                          _saveProfileData // Call the function to save data and navigate
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
