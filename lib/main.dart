import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:blogger/sign_in_screen.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDzWLr9_bpb_Q-KCBbs0XcQjhITKIK5OQ0",
      authDomain: "YOUR_AUTH_DOMAIN",
      projectId: "blogapp-3e075",
      messagingSenderId: "242662399474",
      appId: "1:242662399474:android:b656f1c15f3be576281f6b",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blogger',
      home: SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
