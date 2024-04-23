import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/theme_manager.dart'; // Import ThemeManager
import 'package:flutter_application_1/views/movie_list_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/views/authentication_view.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase app
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie List App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      home:
          AuthenticationWrapper(), // Use AuthenticationWrapper to manage authentication state
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser; // Check if user is already logged in

    if (user != null) {
      // If user is already logged in, show MovieListView
      return MovieListView();
    } else {
      // If user is not logged in, show AuthenticationView
      return AuthenticationView();
    }
  }
}
