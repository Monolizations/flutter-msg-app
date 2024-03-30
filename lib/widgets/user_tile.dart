import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const UserTile({Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18),
        margin: EdgeInsets.symmetric(
            vertical: 8.0, horizontal: 25), // Add vertical margin
        decoration: BoxDecoration(
          color: Colors.white, // Set background color to white
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black), // Set border color to black
        ),
        child: Row(
          children: [
            SizedBox(width: 12), // Add left margin to the icon
            Padding(
              padding: const EdgeInsets.all(3), // Add padding to icon
              child: Icon(
                Icons.person,
                color: Colors.orange, // Set icon color to orange
              ),
            ),
            SizedBox(width: 12), // Add space between icon and text
            Text(
              text,
              style: TextStyle(
                  color: Colors.orange,
                  fontFamily: 'DefoFont'), // Set text color to orange
            ),
          ],
        ),
      ),
    );
  }
}
