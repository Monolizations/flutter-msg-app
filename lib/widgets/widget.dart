import 'package:flutter/material.dart';

Widget createField(TextEditingController x, String y, bool z) {
  return SizedBox(
    height: 90,
    width: 250,
    child: TextField(
      obscureText: z,
      controller: x,
      decoration: InputDecoration(
        labelText: y,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9.0),
          borderSide:
              const BorderSide(color: Color(0xffb0b0b0)), // Changed to const
        ),
        labelStyle:
            const TextStyle(color: Color(0xffff9a53), fontFamily: 'DefoFont'),
        // You can add more styling options as needed
      ),
    ),
  );
}

Widget createButton(VoidCallback onPress, String x) {
  return SizedBox(
    width: 250,
    height: 50.0,
    child: ElevatedButton(
      onPressed: onPress,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color(0xff000000), // Changed to const
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          const Color(0xffff9a53),
        ),
      ),
      child: Text(
        x,
        style: const TextStyle(fontSize: 22, fontFamily: 'DefoFont'),
      ),
    ),
  );
}
