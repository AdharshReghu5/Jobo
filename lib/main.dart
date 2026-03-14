import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,

        // Main app background (NOT pure black)
        scaffoldBackgroundColor: const Color(0xFF101010),

        // AppBar style (flat, Instagram-like)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),

        // Bottom navigation bar theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF121212),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFFB3B3B3),
        ),

        // Card / post background color
        cardTheme: const CardThemeData(
          color: Color(0xFF121212),
        ),

        // Divider color between posts
        dividerColor: Color(0xFF2F2F2F),
      ),

      // First screen of the app
      home: LoginScreen(),
    );
  }
}
