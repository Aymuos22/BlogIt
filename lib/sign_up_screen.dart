import 'package:flutter/material.dart';
import 'package:blogger/edit_user_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signUpWithEmailAndPassword(BuildContext context) async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // After signing up, navigate to the EditUserInfoScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditUserInfoScreen(userId: _auth.currentUser!.uid),
        ),
      );
    } catch (e) {
      print("Error: ${e.toString()}");
      String errorMessage = "An error occurred. Please try again later.";
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage =
              "The email address is already in use by another account.";
        } else if (e.code == 'weak-password') {
          errorMessage =
              "The password provided is too weak. Please choose a stronger password.";
        } else if (e.code == 'invalid-email') {
          errorMessage =
              "Invalid email address format. Please enter a valid email address.";
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🚀 Sign Up',
          style: TextStyle(fontFamily: 'Pacifico', fontSize: 24),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                icon: Icon(Icons.email, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                icon: Icon(Icons.lock, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                _signUpWithEmailAndPassword(context);
              },
              style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
              child: Text(
                'Sign Up',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
