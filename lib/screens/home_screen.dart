import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentmobile/screens/signin_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("VIEW STALLS"),
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              print("Proceed to SIgn In");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()));
            });
          },
        ),
      ),
    );
  }
}