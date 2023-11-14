import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blogger/all_posts_screen.dart';

class EditUserInfoScreen extends StatefulWidget {
  final String userId;

  EditUserInfoScreen({required this.userId});

  @override
  _EditUserInfoScreenState createState() => _EditUserInfoScreenState();
}

class _EditUserInfoScreenState extends State<EditUserInfoScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _descriptionController = TextEditingController();

    // Fetch existing user data and populate the controllers
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get()
        .then((userData) {
      if (userData.exists) {
        _usernameController.text = userData['username'];
        _descriptionController.text = userData['description'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Info',
            style: TextStyle(fontFamily: 'Pacifico', color: Colors.black)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            // Update User Description to a TextField
            TextField(
              controller: _descriptionController,
              maxLines: 4, // Allow multiple lines for description
              decoration: InputDecoration(labelText: 'User Description'),
            ),
            SizedBox(height: 16),
            // Enlarged ElevatedButton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save the edited user information
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .set({
                    'username': _usernameController.text,
                    'description': _descriptionController.text,
                  });

                  // Navigate back to user info screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => (AllPostsScreen()),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      color: Colors.white,
                      fontSize: 18, // Adjust the font size
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
