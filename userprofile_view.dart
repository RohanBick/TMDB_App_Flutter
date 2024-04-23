import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/views/authentication_view.dart';
import 'package:flutter_application_1/views/movie_list_view.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/views/profile_view.dart';

class UserProfileView extends StatelessWidget {
  final String userUid;

  UserProfileView({required this.userUid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserDataAndImage(userUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        Map<String, dynamic> userData = snapshot.data!;
        String imageUrl = userData['imageUrl'] ??
            'assets/Roll.png'; // Use default asset if no imageUrl found

        return Scaffold(
          appBar: AppBar(
            title: Text('Edit Profile'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: imageUrl != 'assets/Roll.png'
                      ? NetworkImage(imageUrl) as ImageProvider<Object>
                      : AssetImage(imageUrl) as ImageProvider<Object>,
                ),
                SizedBox(height: 20),
                Text(
                  'Username: ${userData['userName']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'First Name: ${userData['firstName']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Last Name: ${userData['lastName']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Country: ${userData['country']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Bio: ${userData['bio']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Age: ${userData['age']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileView(userUid: userUid),
                      ),
                    );
                  },
                  child: Text('Edit Profile'),
                ),
                SizedBox(height: 10), // Add spacing between buttons
                ElevatedButton(
                  onPressed: () => _logout(context), // Call _logout method
                  child: Text('Logout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getUserDataAndImage(String userUid) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users').child(userUid);
    DatabaseEvent event = await userRef.once();
    DataSnapshot snapshot = event.snapshot;
    Map<String, dynamic> userData = {};

    // Safely extract data and ensure types are correct
    if (snapshot.value != null) {
      userData =
          Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
    }

    try {
      String downloadURL = await FirebaseStorage.instance
          .ref('profile_images/$userUid.jpg')
          .getDownloadURL();
      userData['imageUrl'] =
          downloadURL; // Set the imageURL in userData if found
    } catch (e) {
      userData['imageUrl'] =
          'assets/Roll.png'; // Set to default image if no image is found in storage
    }

    return userData;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationView(),
        ),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
