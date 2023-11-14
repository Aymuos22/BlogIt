import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayUserInfoScreen extends StatelessWidget {
  final String userId;

  DisplayUserInfoScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Info',
          style: TextStyle(fontFamily: 'Pacifico', color: Colors.black),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/images/user.jpg'),
            ),
            SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return CircularProgressIndicator();
                }

                var user = snapshot.data!;
                var username = user['username'] as String?;
                var description = user['description'] as String?;

                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username: ${username ?? "N/A"}',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'User Description: ${description ?? "N/A"}',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
