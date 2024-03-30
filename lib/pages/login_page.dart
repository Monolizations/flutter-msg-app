import 'package:flutter/material.dart';
import 'package:katalk/auth/auth_service.dart';
import 'package:katalk/pages/home_page.dart';
import 'package:katalk/pages/register_page.dart';
import '../widgets/widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController credentialField = TextEditingController();
  TextEditingController passField = TextEditingController();

  void loginAuth(BuildContext context) async {
    final authService = AuthService();
    final parentContext = context;

    try {
      // Logging in using email
      await authService.signInWithEmailAndPassword(
          credentialField.text, passField.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      showDialog(
          context: parentContext,
          builder: (context) => AlertDialog(
                title: Text(e.toString()),
              ));
    }
  }

  @override
  void dispose() {
    credentialField.dispose();
    passField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
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
            createField(credentialField, "Email", false), // Change the label
            createField(passField, "Password", true),
            createButton(() => loginAuth(context), "Login"),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Wa pay account? ",
                    style: TextStyle(fontFamily: 'DefoFont')),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return const RegisterScreen();
                    }));
                  },
                  child: const Text("Sign up dri",
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
    );
  }
}
