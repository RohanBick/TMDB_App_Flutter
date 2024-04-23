import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/views/movie_list_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1/views/profile_view.dart';
import 'package:flutter_application_1/views/register_view.dart';
import 'dart:io';
import 'dart:typed_data';

class AuthenticationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: AuthenticationForm(),
    );
  }
}

class AuthenticationForm extends StatefulWidget {
  @override
  _AuthenticationFormState createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    try {
      // Sign in with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If login successful, show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login success!! Welcome to TMDB'),
      ));

      // Navigate to the MovieListView
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MovieListView(),
        ),
      );
    } catch (e) {
      // If there's an error during login, show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed: $e'),
      ));
    }
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              RegisterView()), // Navigate to the register view
    );
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
            onPressed: () => _login(context),
            child: Text('Login'),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                _navigateToRegister(context), // Navigate to the register view
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
