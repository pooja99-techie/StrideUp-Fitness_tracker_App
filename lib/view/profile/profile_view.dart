import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:strideup_fitness_app/view/login/login_view.dart';
import 'package:strideup_fitness_app/view/profile/edit_profile_view.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/setting_row.dart';
import '../../common_widget/title_subtitle_cell.dart';
// import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool positive = false;

  String _height = 'Loading...';
  String _weight = 'Loading...';
  String _dateOfBirth = 'Loading...';

  List accountArr = [
    {"image": "assets/img/p_personal.png", "name": "Personal Data", "tag": "1"},
    {"image": "assets/img/p_achi.png", "name": "Achievement", "tag": "2"},
    {
      "image": "assets/img/p_activity.png",
      "name": "Activity History",
      "tag": "3"
    },
    {
      "image": "assets/img/p_workout.png",
      "name": "Workout Progress",
      "tag": "4"
    }
  ];

  List otherArr = [
    {"image": "assets/img/p_contact.png", "name": "Contact Us", "tag": "5"},
    {"image": "assets/img/p_privacy.png", "name": "Privacy Policy", "tag": "6"},
    {"image": "assets/img/p_setting.png", "name": "Setting", "tag": "7"},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch user data when the widget is initialized
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    print('DEBUG: _fetchUserData started'); // Print at the very beginning

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('DEBUG: User is logged in with UID: ${currentUser.uid}'); // Print if user exists

      try {
        print('DEBUG: Attempting to fetch document for UID: ${currentUser.uid}'); // Print before the fetch
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        print('DEBUG: Firestore fetch operation completed'); // Print after the fetch

        if (userDoc.exists) {
          print('DEBUG: User document found in Firestore.'); // Print if document exists
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          print('DEBUG: Fetched raw user data: $data'); // Print the raw data map

          setState(() {
            print('DEBUG: Inside setState - updating state variables'); // Print inside setState

            final fetchedHeight = data['height'];
            final fetchedWeight = data['weight'];
            final fetchedDateOfBirth = data['dateOfBirth']; // Fetch dateOfBirth for age

            _height = fetchedHeight != null ? fetchedHeight.toString() : 'Height Missing';
            _weight = fetchedWeight != null ? fetchedWeight.toString() : 'Weight Missing';
            // Basic age calculation (more robust logic needed for a real app)
            if (fetchedDateOfBirth != null && fetchedDateOfBirth is String) {
              try {
                final parts = fetchedDateOfBirth.split('/'); // Assuming "MM/DD/YYYY"
                if(parts.length == 3) {
                  final month = int.parse(parts[0]);
                  final day = int.parse(parts[1]);
                  final year = int.parse(parts[2]);
                  final dateOfBirth = DateTime(year, month, day);
                  final today = DateTime.now();
                  int age = today.year - dateOfBirth.year;
                  if (today.month < dateOfBirth.month || (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
                    age--;
                  }
                  _dateOfBirth = age.toString();
                } else {
                  _dateOfBirth = 'Invalid Date Format';
                }
              } catch(e) {
                _dateOfBirth = 'Age Calc Error';
                print('DEBUG: Error calculating age: $e');
              }
            } else {
              _dateOfBirth = 'Date Missing';
            }


            print('DEBUG: State variables updated: Height=$_height, Weight=$_weight, Age=$_dateOfBirth'); // Print updated state

          });
          print('DEBUG: setState completed'); // Print after setState block
        } else {
          print('DEBUG: User document NOT found in Firestore for UID: ${currentUser.uid}'); // Print if document NOT found
          setState(() {
            _height = 'Not set';
            _weight = 'Not set';
            _dateOfBirth = 'Not set';
          });
        }
      } catch (e) {
        print('DEBUG: *** ERROR fetching user data: $e ***'); // Print if an error occurs
        setState(() {
          _height = 'Error';
          _weight = 'Error';
          _dateOfBirth = 'Error';
        });
      }
    } else {
      print('DEBUG: No user logged in when _fetchUserData was called.'); // Print if no user
      setState(() {
        _height = 'N/A';
        _weight = 'N/A';
        _dateOfBirth = 'N/A';
      });
    }
    print('DEBUG: _fetchUserData finished'); // Print at the very end
  }

  @override
  Widget build(BuildContext context) {

    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          "Profile",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () async { // Make the function async
              try {
                await FirebaseAuth.instance.signOut();

                // Navigate to the LoginView screen using MaterialPageRoute
                // and remove all other routes from the stack.
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginView()), // <-- Create the route for your LoginView
                      (Route<dynamic> route) => false, // <-- This predicate removes all routes below the new one
                );

                print("User signed out and navigated to login!"); // Optional: print statement
              } catch (e) {
                print("Error signing out: $e");
                // Optionally show an error message to the user
              }
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      "assets/img/u2.png",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$userName",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Lose a Fat Program",
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 25,
                    child: RoundButton(
                      title: "Edit",
                      type: RoundButtonType.bgGradient,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileView(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row( // Removed const from here because child widgets will be dynamic
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "$_height cm", // Use the state variable for height
                      subtitle: "Height",
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "$_weight kg", // Use the state variable for weight
                      subtitle: "Weight",
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "$_dateOfBirth yo", // Use the state variable for age
                      subtitle: "Age",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: accountArr.length,
                      itemBuilder: (context, index) {
                        var iObj = accountArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Other",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: otherArr.length,
                      itemBuilder: (context, index) {
                        var iObj = otherArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
