import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentmobile/screens/timeline_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _firstNameTextController = TextEditingController();
  final TextEditingController _middleNameTextController = TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _contactNumberTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _retypePasswordTextController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _contactNumberError;
  String? _emailError;

  DateTime? _selectedDate;
  bool _passwordVisible = false;
  bool _retypePasswordVisible = false;
  bool _passwordsMatch = true; // To indicate if passwords match

Future<void> _registerUser() async {

    // Validate email format before proceeding
  String email = _emailTextController.text;
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
    // Show error message for invalid email format
    _showError("Please enter a valid email address");
    return;
  }

      // Check for empty fields
  if (_firstNameTextController.text.isEmpty) {
    _showError("First Name cannot be empty");
    return;
  }
  if (_middleNameTextController.text.isEmpty) {
    _showError("Middle Name cannot be empty");
    return;
  }
  if (_lastNameTextController.text.isEmpty) {
    _showError("Last Name cannot be empty");
    return;
  }
  if (_userNameTextController.text.isEmpty) {
    _showError("Username cannot be empty");
    return;
  }
  
  if (_dobController.text.isEmpty) {
    _showError("Date of Birth cannot be empty");
    return;
  }
    // Validate phone number format before proceeding
  String phoneNumber = _contactNumberTextController.text;
  if (phoneNumber.length != 11 || !RegExp(r'^\d{11}$').hasMatch(phoneNumber)) {
    // Show error message for invalid phone number format
    _showError("Contact number must be 11 digits");
    return;
  }

  if (!_passwordsMatch) {
    // Show error message for password mismatch
    _showError("Passwords do not match");
    return;
  }

  if (_passwordTextController.text.length < 8) {
    // Show error message for password length
    _showError("Password must be at least 8 characters long");
    return;
  }

  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailTextController.text,
      password: _passwordTextController.text,
    );

    String userId = userCredential.user!.uid;
    var usersCollection = FirebaseFirestore.instance.collection('users');
    var userRef = usersCollection.doc(userId);

    Timestamp now = Timestamp.now();

    await userRef.set({
      'first_name': _firstNameTextController.text,
      'middle_name': _middleNameTextController.text, // Added middle name
      'last_name': _lastNameTextController.text,
      'username': _userNameTextController.text,
      'contact_number': _contactNumberTextController.text,
      'email': _emailTextController.text,
      'date_of_birth': _selectedDate?.toIso8601String(), // Added Date of Birth
      'created_at': now,
      'status': 'Pending',
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TimelineScreen(userId: userId),
      ),
    );
  } catch (error) {
    print("Failed to register user: $error");
    // Add proper error handling here
  }
}

// Function to show error message
void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Back icon with white color
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
        title: const Text(""), // Empty title to avoid spacing issues
        flexibleSpace: const Center( // Center the content
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the text and icon
            mainAxisSize: MainAxisSize.min, // Minimize the space taken by the Row
            children: [
              Icon(Icons.person_add, color: Colors.white), // Icon next to the text
              SizedBox(width: 8), // Space between icon and text
              Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Set text color to white
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 31, 232, 37), // Set background color to green
        elevation: 1.0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 0), // Reduced top padding
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),

                // Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the left
                  children: [
                    _buildTextField(
                      controller: _emailTextController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      onChanged: (value) {
                        setState(() {
                          // Validate the email input on change
                          if (value.isEmpty) {
                            _emailError = null; // No error if input is empty
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            _emailError = 'Please enter a valid email address';
                          } else {
                            _emailError = null; // Clear error if valid
                          }
                        });
                      },
                    ),
                    // Display error message if there is one
                    if (_emailError != null)
                      Text(
                        _emailError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),

                // First Name
                _buildTextField(
                  controller: _firstNameTextController,
                  label: 'First Name',
                  icon: Icons.person_outline, onChanged: (String ) {  },
                ),

                // Middle Name
                _buildTextField(
                  controller: _middleNameTextController,
                  label: 'Middle Name',
                  icon: Icons.person_outline, onChanged: (String ) {  },
                ),

                // Last Name
                _buildTextField(
                  controller: _lastNameTextController,
                  label: 'Last Name',
                  icon: Icons.person_outline, onChanged: (String ) {  },
                ),

                // Username
                _buildTextField(
                  controller: _userNameTextController,
                  label: 'Username',
                  icon: Icons.person_outline, onChanged: (String ) {  },
                ),

                // Date of Birth
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: 'mm/dd/yyyy',
                      prefixIcon: const Icon(
                      Icons.calendar_today,
                      size: 19, color: Color.fromARGB(255, 88, 86, 86),// 
                    ),
                      suffixIcon: IconButton(iconSize: 20,
                        icon: const Icon(Icons.calendar_month_sharp),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              setState(() {
                                _selectedDate = selectedDate;
                                // Update the controller with the formatted date
                                _dobController.text = "${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}";
                              });
                            }
                          });
                        },
                      ),
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
                      LengthLimitingTextInputFormatter(10), // Limit input length to 10
                      DateTextInputFormatter() // Custom formatter for date input
                    ],
                    onChanged: (value) {
                      // Update the selected date based on user input
                      _updateSelectedDate(value);
                    },
                  ),
                ),

              // Contact Number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the left
                children: [
                  _buildTextField(
                    controller: _contactNumberTextController,
                    label: 'Contact Number',
                    icon: Icons.phone,
                    onChanged: (value) {
                      setState(() {
                        // Validate the input on change
                        if (value.isEmpty) {
                          _contactNumberError = null; // No error if input is empty
                        } else if (value.length != 11 || !RegExp(r'^\d{11}$').hasMatch(value)) {
                          _contactNumberError = 'Contact number must be 11 digits';
                        } else {
                          _contactNumberError = null; // Clear error if valid
                        }
                      });
                    },
                  ),
                  // Display error message if there is one
                  if (_contactNumberError != null)
                    Text(
                      _contactNumberError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),

                // Password
                _buildPasswordField(
                  controller: _passwordTextController,
                  label: 'Enter Password',
                  isVisible: _passwordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  onChanged: (value) {
                    // Check passwords match whenever the user types in the password field
                    _checkPasswordsMatch();
                  },
                ),

                // Retype Password
                Column(
                  children: [
                    _buildPasswordField(
                      controller: _retypePasswordTextController,
                      label: 'Retype Password',
                      isVisible: _retypePasswordVisible,
                      toggleVisibility: () {
                        setState(() {
                          _retypePasswordVisible = !_retypePasswordVisible;
                        });
                      },
                      onChanged: (value) {
                        // Check passwords match whenever the user types in the retype password field
                        _checkPasswordsMatch();
                      },
                    ),

                    // Password match error message directly below the retype password field
                    Container(
                      alignment: Alignment.centerLeft, // Align to the left
                      child: _passwordsMatch || _retypePasswordTextController.text.isEmpty
                          ? const SizedBox.shrink() // Hide the message if passwords match or retype field is empty
                          : const Text(
                              "Passwords do not match",
                              style: TextStyle(color: Colors.red, fontSize: 12), // Smaller font size
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // Sign Up Button in Green Container
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 24, 213, 30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: _registerUser,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                  ), 
                ),
                  const SizedBox(height: 12,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkPasswordsMatch() {
    setState(() {
      // Check for match in both password fields
      _passwordsMatch = _passwordTextController.text == _retypePasswordTextController.text;
    });
  }

  // Function to update selected date based on user input
  void _updateSelectedDate(String value) {
    if (value.length == 10) {
      List<String> dateParts = value.split('/');
      if (dateParts.length == 3) {
        try {
          int month = int.parse(dateParts[0]);
          int day = int.parse(dateParts[1]);
          int year = int.parse(dateParts[2]);
          setState(() {
            _selectedDate = DateTime(year, month, day);
          });
        } catch (e) {
          // Handle parsing error
          print("Error parsing date: $e");
        }
      }
    } else {
      setState(() {
        _selectedDate = null; // Reset if input is invalid
      });
    }
  }
}

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
     required Function(String) onChanged, // Added onChanged parameter
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Reduced bottom margin for spacing
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 13,
          ), // Ensure label color is black
          prefixIcon: Icon(icon, size: 20), // Smaller icon size
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green), // Green border when focused
          ),
        ),
        keyboardType: TextInputType.phone,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Reduced bottom margin for spacing
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black, fontSize: 13), // Ensure label color is black
          prefixIcon: const Icon(Icons.lock_outline, size: 20), // Smaller icon size
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              size: 20, // Smaller icon size
            ),
            onPressed: toggleVisibility,
          ),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green), // Green border when focused
          ),
        ),
      ),
    );
  }

// Custom TextInputFormatter for date formatting
class DateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Prevent removing slashes or hint
    if (newText.length > 0) {
      newText = newText.replaceAll('/', ''); // Remove existing slashes for easier formatting
    }

    // Format date as mm/dd/yyyy
    if (newText.length >= 2) {
      newText = newText.substring(0, 2) + '/' + newText.substring(2); // Add a slash after the month
    }
    if (newText.length >= 5) {
      newText = newText.substring(0, 5) + '/' + newText.substring(5); // Add a slash after the day
    }

    // Ensure the new text is no longer than 10 characters
    newText = newText.substring(0, newText.length > 10 ? 10 : newText.length);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length), // Move cursor to the end
    );
  }
} 