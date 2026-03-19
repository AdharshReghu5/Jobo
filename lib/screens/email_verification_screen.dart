import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'setup_profile_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {

  bool loading = false;

  Future<void> checkVerification() async {

    setState(() => loading = true);

    await FirebaseAuth.instance.currentUser!.reload();

    if (FirebaseAuth.instance.currentUser!.emailVerified) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SetupProfileScreen(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not verified yet")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF080808),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(
              "Verify your email",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),

            const SizedBox(height: 20),

            const Text(
              "Check your inbox and verify your email",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: loading ? null : checkVerification,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("I have verified"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}