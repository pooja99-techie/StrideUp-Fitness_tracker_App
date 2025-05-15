import 'package:flutter/material.dart';
import 'package:strideup_fitness_app/view/main_tab/main_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import this package

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  // We don't strictly need to fetch the user here,
  // we can access it directly in the build method.

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    // Get the current user from Firebase Authentication
    // The `?` makes it null-safe in case currentUser is null
    // The `?? 'User'` provides a default name if displayName is null
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName ?? 'User'; // Use a default if display name is not set

    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Container(
          width: media.width,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: media.width * 0.1,
              ),
              Image.asset(
                "assets/img/welcome.png",
                width: media.width * 0.75,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
              // Use the dynamic userName here
              Text(
                "Welcome, $userName", // <-- Changed this line
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                "You are all set now, let’s reach your\ngoals together with us",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.gray, fontSize: 12),
              ),
              const Spacer(),
              RoundButton(
                  title: "Go To Home",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainTabView()));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
