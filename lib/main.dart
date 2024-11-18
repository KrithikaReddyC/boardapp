import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => SplashScreen(), // Splash Screen as the entry point
        '/home': (context) => HomePage(), // Home Page
        '/profile': (context) => ProfilePage(), // Profile Page
        '/settings': (context) => SettingsPage(), // Settings Page
        '/login': (context) => LoginPage(), // Login Page
      },
    );
  }
}
