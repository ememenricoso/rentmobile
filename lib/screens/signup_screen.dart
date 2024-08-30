import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentmobile/reusable_widgets/reusable_widgets.dart';
import 'package:rentmobile/screens/timeline_screen.dart';
import 'package:rentmobile/utils/color_utils.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _firstNameTextController = TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _contactNumberTextController = TextEditingController();

  Future<void> initializeCounter() async {
  var counterDocRef = FirebaseFirestore.instance.collection('counters').doc('user_id_counter');
  
  var counterDoc = await counterDocRef.get();
  if (!counterDoc.exists) {
    await counterDocRef.set({'count': 0}); // Initialize counter at 0
  }
}


   Future<String> getNextAvailableId() async {
  try {
    var usersCollection = FirebaseFirestore.instance.collection('users');

    // Fetch all documents and their IDs
    var querySnapshot = await usersCollection.get();
    
    if (querySnapshot.docs.isEmpty) {
      // No existing documents, start with '01'
      return '01';
    }

    // Extract IDs and determine the maximum existing ID
    List<int> ids = querySnapshot.docs.map((doc) {
      return int.tryParse(doc.id) ?? 0;
    }).toList();

    int maxId = ids.isNotEmpty ? ids.reduce((a, b) => a > b ? a : b) : 0;
    int nextId = maxId + 1;

    // Format ID with leading zeros
    return nextId.toString().padLeft(2, '0');
  } catch (error) {
    print("Failed to get next available ID: $error");
    return "01"; // Default ID in case of error
  }
}


  Future<void> _registerUser() async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailTextController.text,
      password: _passwordTextController.text,
    );

    String formattedId = await getNextAvailableId();

    var usersCollection = FirebaseFirestore.instance.collection('users');
    var newUserRef = usersCollection.doc(formattedId);

    // Ensure the document does not already exist
    var existingDoc = await newUserRef.get();
    if (existingDoc.exists) {
      throw Exception("Document with ID $formattedId already exists.");
    }

    await newUserRef.set({
      'first_name': _firstNameTextController.text,
      'last_name': _lastNameTextController.text,
      'username': _userNameTextController.text,
      'contact_number': _contactNumberTextController.text,
      'email': _emailTextController.text,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'Pending', // Example: Set initial status as Pending
    });

    print("User info added to Firestore with ID: $formattedId");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TimelineScreen(userId: formattedId),
      ),
    );
  } catch (error) {
    print("Failed to register user: $error");
    // Add proper error handling here
  }
}

  @override
  void initState() {
    super.initState();
    // Ensure the counter document is initialized
    initializeCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                reusableTextField(
                  "First Name",
                  Icons.person_outline,
                  false,
                  _firstNameTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Last Name",
                  Icons.person_outline,
                  false,
                  _lastNameTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "UserName",
                  Icons.person_outline,
                  false,
                  _userNameTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Contact Number",
                  Icons.phone,
                  false,
                  _contactNumberTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Email Address",
                  Icons.email_outlined,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outlined,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(height: 20),
                firebaseUIButton(context, "Sign Up", _registerUser),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
