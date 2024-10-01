import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rentmobile/reusable_widgets/reusable_widgets.dart';
import 'package:rentmobile/screens/reset_password.dart';
import 'package:rentmobile/screens/signup_screen.dart';
import 'package:rentmobile/screens/timeline_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  bool _isPasswordVisible = false; // To track password visibility



Future<void> _checkApplicationStatus(String email) async {
  try {
    // Check in the users collection
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // If user exists, navigate to TimelineScreen
    if (userSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userSnapshot.docs.first;

      // Always navigate to TimelineScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TimelineScreen(userId: userDoc.id)),
      );
    } else {
      print("User not found.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found.")),
      );
      // No redirection to SignUpScreen here
    }
  } catch (error) {
    print("Error checking application status: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to check application status")),
    );
  }
}

@override
Widget build(BuildContext context) {
   return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "WELCOME TO\n",
                        style: TextStyle(
                          fontSize: 40,
                          color: Color.fromARGB(255, 16, 16, 16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: "CARBONRENT\n\n",
                        style: TextStyle(
                          fontSize: 40,
                          color: Color.fromARGB(255, 60, 218, 28),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                reusableTextField("Enter Email", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(height: 20),
                _passwordField(), // Use the _passwordField method here
                const SizedBox(height: 5),
                forgetPassword(context),
                firebaseUIButton(context, "Sign In", () async {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _emailTextController.text,
                            password: _passwordTextController.text);

                    // Check application status after successful sign-in
                    await _checkApplicationStatus(userCredential.user!.email!);
                  } catch (error) {
                    print("Error signing in: $error");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to sign in")),
                    );
                  }
                }),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }


 Widget _passwordField() {
    return TextField(
      controller: _passwordTextController,
      obscureText: !_isPasswordVisible, // Toggle obscure text
      decoration: InputDecoration(
        labelText: "Enter Password",
        labelStyle: const TextStyle(
          color: Colors.black, // Change label text color to black
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 16.0, // Set the desired size
          color: Colors.black, // Set the desired color
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible; // Toggle the visibility
            });
          },
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            width: 2,
            color: Color.fromARGB(255, 60, 218, 28), // Green border color when focused
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 0, 0, 0), // Lighter green border color when not focused
          ),
        ),
      ),
      style: const TextStyle(
        color: Colors.black, // Change the text color to black
      ),
    );
  }


  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
            style: TextStyle(color: Color.fromARGB(179, 11, 11, 11))),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Color.fromARGB(255, 8, 8, 8), fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

 Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Forgot Password?",
              style: const TextStyle(
                color: Color.fromARGB(255, 60, 218, 28),
                decoration: TextDecoration.underline, // Optional: underline to indicate link
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ResetPassword()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
