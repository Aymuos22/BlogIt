import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _createPost(BuildContext context, String title, String content) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      String userEmail = user.email ?? '';
      CollectionReference posts =
          FirebaseFirestore.instance.collection('posts');

      await posts.add({
        'userId': userId,
        'authorEmail': userEmail,
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Blog post created successfully!',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); 
    } else {
      
      print('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Your Blog',
          style: TextStyle(fontFamily: 'Pacifico', fontSize: 24),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                icon: Icon(Icons.title, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Content',
                icon: Icon(Icons.description, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                _createPost(
                    context, _titleController.text, _contentController.text);
              },
              style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
              child: Text(
                'Publish',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
