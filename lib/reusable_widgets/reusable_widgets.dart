import 'package:flutter/material.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
  );
}

TextField reusableTextField(
  String text, 
  IconData icon, 
  bool isPasswordType,
  TextEditingController controller
) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: const Color.fromARGB(255, 10, 10, 10), // Set cursor color
    style: TextStyle(color: const Color.fromARGB(255, 9, 9, 8).withOpacity(0.9)), // Text color
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon, 
        size: 18, // Adjusted icon size
        color: const Color.fromARGB(179, 9, 9, 9), // Icon color
      ),
      labelText: text,
      labelStyle: TextStyle(color: const Color.fromARGB(255, 12, 12, 12).withOpacity(0.9)), // Label color
      filled: true,
      fillColor: Colors.transparent, // Transparent background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0), // Slightly curved edges
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 10, 10, 10), // Border color
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0), // Slightly curved edges when focused
        borderSide: const BorderSide(
          width: 2,
          color: Color.fromARGB(255, 77, 212, 19), // Green border color when focused
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0), // Match the radius with focused border
        borderSide: const BorderSide(
          color: Colors.black, // Border color when not focused
        ),
      ),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}



Container firebaseUIButton(BuildContext context, String title, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
/*     decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
 */    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white;
            }
            return const Color.fromARGB(255, 54, 206, 20);
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      child: Text(
        title,
        style: const TextStyle(
            color: Color.fromARGB(221, 255, 255, 255), fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}