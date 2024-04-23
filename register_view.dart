import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/views/movie_list_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1/views/profile_view.dart';
import 'dart:io';
import 'dart:typed_data';

class RegisterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Future<void> _register(BuildContext context) async {
  //   try {
  //     UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Account created!'),
  //     ));
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => ProfileView(userUid: userCredential.user!.uid),
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error registering user: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Error registering user: $e'),
  //     ));
  //   }
  // }
  Future<void> _register(BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save additional user data to Firebase Realtime Database
      await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        // Add more fields as needed
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Account created!'),
      ));

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileView(userUid: userCredential.user!.uid),
        ),
      );
    } catch (e) {
      print('Error registering user: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error registering user: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _register(context),
            child: Text('Create Account'),
          ),
        ],
      ),
    );
  }
}
