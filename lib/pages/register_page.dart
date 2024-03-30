import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:katalk/auth/auth_service.dart';
import 'package:katalk/pages/login_page.dart';
import '../widgets/widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController unameField = TextEditingController();
  TextEditingController emailField = TextEditingController();
  TextEditingController confpField = TextEditingController();
  TextEditingController passField = TextEditingController();

  void regAuth(BuildContext context) {
    final _auth = AuthService();

    // Validate email format
    if (!emailField.text.contains('@')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Invalid email format",
            style: TextStyle(fontFamily: 'DefoFont'),
          ),
        ),
      );
      return;
    }

    // Validate password length
    if (passField.text.length < 6) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Password must be at least 6 characters long",
            style: TextStyle(fontFamily: 'DefoFont'),
          ),
        ),
      );
      return;
    }

    // Validate username length
    if (unameField.text.length < 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Username must be at least 3 characters long",
            style: TextStyle(fontFamily: 'DefoFont'),
          ),
        ),
      );
      return;
    }

    // Check if any field is empty
    if (passField.text.isEmpty ||
        unameField.text.isEmpty ||
        confpField.text.isEmpty ||
        emailField.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Empty fields, try again",
            style: TextStyle(fontFamily: 'DefoFont'),
          ),
        ),
      );
      return;
    }

    // Check if passwords match
    if (passField.text != confpField.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Password don't match",
            style: TextStyle(fontFamily: 'DefoFont'),
          ),
        ),
      );
      return;
    }

    // Attempt registration
    try {
      _auth.signUpWithEmailPassword(
        emailField.text,
        passField.text,
        unameField.text,
      ); // Pass the username parameter

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration successful!',
            style: TextStyle(fontFamily: 'DefoFont'),
          ),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    unameField.dispose();
    emailField.dispose();
    confpField.dispose();
    passField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/rsz_11logo.png", width: 180),
              const Text(
                "kaTalk",
                style: TextStyle(fontSize: 45, fontFamily: 'DefoFont'),
              ),
              const SizedBox(
                height: 20,
              ),
              createField(emailField, "Email", false),
              createField(unameField, "Username", false),
              createField(passField, "Password", true),
              createField(confpField, "Confirm Password", true),
              createButton(() {
                regAuth(context);
              }, "Register"),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Naa nay account? ",
                      style: TextStyle(fontFamily: 'DefoFont')),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return const LoginScreen();
                      }));
                    },
                    child: const Text("Log in na!",
                        style: TextStyle(fontFamily: 'DefoFont')),
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Color(0xffff9a53)),
                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                        (states) => Colors.transparent,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
