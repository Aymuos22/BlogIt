import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blogger/create_post_screen.dart';
import 'package:blogger/sign_in_screen.dart';
import 'package:blogger/display_user_info_screen.dart';
import 'package:blogger/edit_user_info_screen.dart';

class AllPostsScreen extends StatefulWidget {
  @override
  _AllPostsScreenState createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  late Stream<QuerySnapshot> _filteredPostsStream;
  final TextEditingController _searchController = TextEditingController();

  Stream<QuerySnapshot> _getFilteredPosts(String query) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('title', isGreaterThanOrEqualTo: query.toUpperCase())
        .snapshots();
  }

  Future<void> _deletePost(String postId, String userId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.uid == userId) {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    } else {
      // User does not have permission to delete this post
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(
              'Permission Denied',
              style: TextStyle(fontFamily: 'Pacifico', color: Colors.red),
            ),
            content: Text(
              'You do not have permission to delete this post.',
              style: TextStyle(fontFamily: 'Raleway', color: Colors.black),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Text('OK',
                    style:
                        TextStyle(fontFamily: 'Raleway', color: Colors.black)),
              ),
            ],
          );
        },
      );
    }
  }

  Future<String> getUsername(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      return userData[
          'username']; // Assuming 'username' is the field storing usernames
    }
    return 'Unknown'; // Placeholder if the user doesn't exist or username field is absent
  }

  Future<void> _updatePost(String postId, String newContent) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'content': newContent,
        'updatedAt': FieldValue
            .serverTimestamp(), // Add an 'updatedAt' field to track changes
      });
    } else {
      // User is not logged in
      // Handle according to your app's logic (e.g., prompt user to log in)
      print("error");
    }
  }

  Widget buildSidebar() {
    User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[800],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/images/user.jpg")),
                SizedBox(height: 10),
                Text(
                  user?.displayName ?? "Username", // Use user?.displayName
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          ListTile(
            title: Text('User Info',
                style: TextStyle(fontFamily: 'Raleway', color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DisplayUserInfoScreen(userId: user?.uid ?? ""),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Edit Info',
                style: TextStyle(fontFamily: 'Raleway', color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditUserInfoScreen(userId: user?.uid ?? ""),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredPostsStream = _getFilteredPosts('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Global',
            style: TextStyle(
                fontFamily: 'Pacifico', color: Color.fromARGB(255, 0, 0, 0))),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _signOut(context);
            },
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ],
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
      ),
      drawer: buildSidebar(),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.grey[800],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Title',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    onChanged: (query) {
                      setState(() {
                        _filteredPostsStream = _getFilteredPosts(query);
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _filteredPostsStream = _getFilteredPosts('');
                    });
                  },
                  child: Text('Clear',
                      style: TextStyle(
                          fontFamily: 'Raleway', color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _filteredPostsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (!snapshot.hasData ||
                    (snapshot.data as QuerySnapshot).docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No posts found.',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  );
                }

                var posts = (snapshot.data as QuerySnapshot).docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    var title = post['title'];
                    var content = post['content']; // Placeholder for content
                    var author = post['userId'];
                    var timestamp = post['timestamp'];

                    return FutureBuilder<String>(
                      future: getUsername(author),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          var username = snapshot.data ?? 'Unknown';
                          User? currentUser = FirebaseAuth.instance.currentUser;
                          bool isCurrentUserPost =
                              currentUser != null && currentUser.uid == author;

                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.all(8),
                            color: isCurrentUserPost
                                ? Color.fromARGB(255, 183, 239, 211)
                                : Colors.grey[900],
                            child: ExpansionTile(
                              title: Text(title,
                                  style: TextStyle(
                                      fontFamily: 'Pacifico',
                                      fontSize: 24,
                                      color: Colors.white)),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('$content',
                                          style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 20,
                                              color: Colors.white)),
                                      Text(
                                        'Author: $username',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontFamily: 'Raleway',
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        'Timestamp: ${timestamp.toDate().toString()}',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontFamily: 'Raleway',
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                      SizedBox(height: 16),
                                      isCurrentUserPost
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.delete),
                                                  onPressed: () {
                                                    // Show delete confirmation dialog
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          dialogContext) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Delete Post',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Pacifico',
                                                                  color: Colors
                                                                      .white)),
                                                          content: Text(
                                                            'Are you sure you want to delete this post?',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Raleway',
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                Navigator.of(
                                                                        dialogContext)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  'Cancel',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Raleway',
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                await _deletePost(
                                                                    post.id,
                                                                    post[
                                                                        'userId']);
                                                                Navigator.of(
                                                                        dialogContext)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  'Delete',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Raleway',
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {
                                                    // Show edit dialog for updating post content
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          dialogContext) {
                                                        TextEditingController
                                                            _editContentController =
                                                            TextEditingController(
                                                                text: content);
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Edit Post',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Pacifico',
                                                                  color: Colors
                                                                      .white)),
                                                          content: TextField(
                                                            controller:
                                                                _editContentController,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  'New Content',
                                                              border:
                                                                  OutlineInputBorder(),
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        dialogContext)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  'Cancel',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Raleway',
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                await _updatePost(
                                                                    post.id,
                                                                    _editContentController
                                                                        .text);
                                                                Navigator.of(
                                                                        dialogContext)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  'Update',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Raleway',
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0))),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Logout',
              style: TextStyle(fontFamily: 'Pacifico', color: Colors.black)),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontFamily: 'Raleway', color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Cancel logout
              },
              child: Text('Cancel',
                  style: TextStyle(fontFamily: 'Raleway', color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Confirm logout
              },
              child: Text('Logout',
                  style: TextStyle(fontFamily: 'Raleway', color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    bool confirmed = await _showLogoutConfirmationDialog(context);
    if (confirmed) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }
  }
}
