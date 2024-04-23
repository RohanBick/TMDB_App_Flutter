import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/views/authentication_view.dart';
import 'package:flutter_application_1/views/movie_list_view.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileView extends StatefulWidget {
  final String userUid;

  ProfileView({required this.userUid});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('users');

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;
  String _imageUrl = 'assets/Roll.png'; // Default image

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage(); // Load user profile image on init
    _loadUserProfileDetails(); // Load user profile details on init
  }

  Future<void> _loadUserProfileImage() async {
    try {
      String downloadURL = await FirebaseStorage.instance
          .ref('profile_images/${widget.userUid}.jpg')
          .getDownloadURL();
      setState(() {
        _imageUrl = downloadURL;
      });
    } catch (e) {
      print('Failed to load image: $e');
      setState(() {
        _imageUrl = 'assets/Roll.png'; // Keep default image if loading fails
      });
    }
  }

  Future<void> _loadUserProfileDetails() async {
    try {
      // Fetch user details from Firebase Realtime Database
      DatabaseEvent event = await _userRef.child(widget.userUid).once();
      DataSnapshot snapshot = event.snapshot;

      Map<dynamic, dynamic>? userData =
          snapshot.value as Map<dynamic, dynamic>?;

      if (userData != null) {
        setState(() {
          // Set text controllers with user details fetched from the database
          _userNameController.text = userData['userName'] ?? '';
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _ageController.text = userData['age'] ?? '';
          _countryController.text = userData['country'] ?? '';
          _bioController.text = userData['bio'] ?? '';
        });
      }
    } catch (e) {
      print('Failed to load user details: $e');
    }
  }

  Future<void> _saveDetails(BuildContext context) async {
    try {
      await _userRef.child(widget.userUid).set({
        'userName': _userNameController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': _ageController.text.trim(),
        'country': _countryController.text.trim(),
        'bio': _bioController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Details Saved!'),
      ));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MovieListView()),
      );
    } catch (e) {
      print('Error saving user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving user details: $e'),
      ));
    }
  }

  Future<void> _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      // Get the reference to the Firebase Storage location
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${widget.userUid}.jpg');

      // Upload the image file to Firebase Storage
      final UploadTask uploadTask = storageRef.putFile(_imageFile!);
      setState(() {
        _isLoading = true; // Show loading indicator while uploading
      });

      // Await for the completion of the upload task
      await uploadTask.whenComplete(() {
        setState(() {
          _isLoading = false; // Hide loading indicator after upload completes
        });
      });

      // Get the download URL of the uploaded image
      String downloadURL = await storageRef.getDownloadURL();

      // Update the _imageUrl variable and rebuild the widget tree
      setState(() {
        _imageUrl = downloadURL;
      });

      // Perform any additional operations with the download URL as needed
      print('Image uploaded successfully. Download URL: $downloadURL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Editing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _imageUrl != 'assets/Roll.png'
                    ? NetworkImage(_imageUrl) as ImageProvider
                    : AssetImage(_imageUrl) as ImageProvider,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _uploadImage(),
                child: Text('Upload Image'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'User Name'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _countryController,
                decoration: InputDecoration(labelText: 'Country'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Bio'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveDetails(context),
                child: Text('Save Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
