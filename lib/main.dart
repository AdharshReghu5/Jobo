import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobo/screens/login_screen.dart';
import 'package:jobo/screens/setup_profile_screen.dart';
import 'package:jobo/screens/main_screen.dart';
import 'package:jobo/firebase_options.dart';

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
      home: const AuthCheck(),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090909),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3797EF),
          secondary: Color(0xFF3797EF),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          bodyLarge: const TextStyle(letterSpacing: 0.2),
          bodyMedium: const TextStyle(letterSpacing: 0.1),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF090909),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3797EF),
            foregroundColor: Colors.white,
          ),
        ),
        dividerColor: const Color(0xFF2F2F2F),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        var user = FirebaseAuth.instance.currentUser;
        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .get(),
          builder: (context, profileSnapshot) {
            if (!profileSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!profileSnapshot.data!.exists) {
              return const SetupProfileScreen();
            }
            return const MainScreen();
          },
        );
      },
    );
  }
}