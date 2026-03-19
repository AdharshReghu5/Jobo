import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/main_screen.dart';
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

      home: const AuthCheck(),

      // 🔥 CUSTOM DARK + BLUE THEME (NO PURPLE)
      theme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF090909),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3797EF),
          secondary: Color(0xFF3797EF),
        ),

        // 🔥 FONT
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
            backgroundColor: Color(0xFF3797EF),
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

        // ❌ Not logged in → go to Login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        var user = FirebaseAuth.instance.currentUser;

        // 🔥 Check if profile exists
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

            // 🔥 If no profile → Setup screen
            if (!profileSnapshot.data!.exists) {
              return const SetupProfileScreen();
            }

            // ✅ Everything ok → Main app
            return const MainScreen();
          },
        );
      },
    );
  }
}