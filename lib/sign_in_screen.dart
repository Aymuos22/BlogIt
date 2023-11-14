import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blogger/sign_up_screen.dart';
import 'package:blogger/all_posts_screen.dart';

class SignInScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signInWithEmailAndPassword(BuildContext context) async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Navigate to the AllPostsScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AllPostsScreen()),
      );
    } catch (e) {
      // Handle login errors
      print(e.toString());
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to sign in. Please check your credentials and try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🔑 Sign In',
          style: TextStyle(fontFamily: 'Pacifico', fontSize: 24),
        ),
        backgroundColor: Colors.teal,
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
                icon: Icon(Icons.email, color: Colors.teal),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                icon: Icon(Icons.lock, color: Colors.teal),
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                _signInWithEmailAndPassword(context);
              },
              style: ElevatedButton.styleFrom(primary: Colors.teal),
              child: Text(
                'Sign In',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()));
              },
              child: Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(color: Colors.teal, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
