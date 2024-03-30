import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katalk/auth/auth_gate.dart';
import 'package:katalk/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Katalk',
      home: AuthGate(),
    );
  }
}
