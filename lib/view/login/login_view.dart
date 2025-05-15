import 'package:flutter/material.dart';
import 'package:strideup_fitness_app/common/colo_extension.dart';
import 'package:strideup_fitness_app/common_widget/round_button.dart';
import 'package:strideup_fitness_app/common_widget/round_textfield.dart';
import 'package:strideup_fitness_app/view/login/complete_profile_view.dart'; // Make sure this is the correct screen to navigate to after login

// Import firebase_auth
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Controllers to get text from text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // isCheck is not used in this view, can be removed if not planned for future features
  // bool isCheck = false;


  // Remember to dispose controllers when the widget is removed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle the login logic
  Future<void> _loginUser() async {
    try {
      // Use Firebase Auth to sign in the user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), // Use trim()
        password: _passwordController.text,
      );

      // --- Add mounted check BEFORE using context after the await ---
      if (!mounted) return;

      // If login is successful, you get a UserCredential
      // You can access the logged-in user via userCredential.user
      User? user = userCredential.user;

      if (user != null) {
        // Optional: Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful! Welcome back ${user.displayName ?? user.email}')),
        );

        // Navigate to the next screen after successful login
        // IMPORTANT: Consider your app's flow. Navigating to CompleteProfileView
        // might not be appropriate for existing users. You might want to navigate
        // to a main app screen or use an authentication gate that checks profile completion.
        Navigator.pushReplacement( // Use pushReplacement to avoid stacking screens
          context,
          MaterialPageRoute(builder: (context) => const CompleteProfileView()), // Adjust navigation as needed
        );
      }

    } on FirebaseAuthException catch (e) {
      // Handle errors from Firebase Authentication

      // --- Add mounted check BEFORE using context in the catch block ---
      if (!mounted) return;

      String errorMessage = 'Login failed.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many failed login attempts. Please try again later.';
      }
      // You can add more specific error handling here

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );

    } catch (e) {
      // Handle any other potential errors

      // --- Add mounted check BEFORE using context in the general catch block ---
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
      );
      print(e); // Log the error for debugging
    }
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: media.height * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Hey there,",
                  style: TextStyle(color: TColor.gray, fontSize: 16),
                ),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                // This SizedBox height appears twice, maybe one is a typo?
                // SizedBox(
                //  height: media.width * 0.04,
                // ),
                const SizedBox(height: 50), // Adjusted height for spacing

                RoundTextField(
                  controller: _emailController, // Link controller
                  hitText: "Email",
                  icon: "assets/img/email.png",
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  controller: _passwordController, // Link controller
                  hitText: "Password",
                  icon: "assets/img/lock.png",
                  obscureText: true,
                  rigtIcon: TextButton(
                      onPressed: () {
                        // TODO: Implement show/hide password functionality
                      },
                      child: Container(
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            "assets/img/show_password.png",
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            color: TColor.gray,
                          ))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton( // Using TextButton for better tap interaction
                      onPressed: () {
                        // TODO: Implement Forgot Password flow
                      },
                      child: Text(
                        "Forgot your password?",
                        style: TextStyle(
                            color: TColor.gray,
                            fontSize: 10,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                RoundButton(
                    title: "Login",
                    onPressed:
                    _loginUser // Call our login function
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                          height: 1,
                          // Use withAlpha instead of withOpacity (0.5 * 255 = 128)
                          color: TColor.gray.withAlpha(128),
                        )),
                    Text(
                      "  Or  ",
                      style: TextStyle(color: TColor.black, fontSize: 12),
                    ),
                    Expanded(
                        child: Container(
                          height: 1,
                          // Use withAlpha instead of withOpacity (0.5 * 255 = 128)
                          color: TColor.gray.withAlpha(128),
                        )),
                  ],
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement Google Sign-In
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: TColor.white,
                          border: Border.all(
                            width: 1,
                            // Use withAlpha instead of withOpacity (0.4 * 255 = 102)
                            color: TColor.gray.withAlpha(102),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.asset(
                          "assets/img/google.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: media.width * 0.04,
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement Facebook Sign-In
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: TColor.white,
                          border: Border.all(
                            width: 1,
                            // Use withAlpha instead of withOpacity (0.4 * 255 = 102)
                            color: TColor.gray.withAlpha(102),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.asset(
                          "assets/img/facebook.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate back to the signup screen
                    Navigator.pop(context); // Assuming this button goes to the signup screen, pop is appropriate
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don’t have an account yet? ",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Register",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
