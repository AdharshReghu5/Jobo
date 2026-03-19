import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'main_screen.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {

  final TextEditingController username = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController bio = TextEditingController();
  final TextEditingController phone = TextEditingController();

  File? image;
  bool loading = false;

  // 📸 Pick Image
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  // ☁️ Upload Image
  Future<String> uploadImage(String uid) async {
    if (image == null) return "";

    final ref = FirebaseStorage.instance
        .ref()
        .child("profile_images")
        .child("$uid.jpg");

    await ref.putFile(image!);

    return await ref.getDownloadURL();
  }

  // 📩 Snackbar
  void showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  // 📱 Phone Validation
  bool isValidPhone(String phone) {
    return RegExp(r"^[0-9]{10}$").hasMatch(phone);
  }

  // 🔍 Username Check
  Future<bool> isUsernameTaken(String username) async {
    var result = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();

    return result.docs.isNotEmpty;
  }

  // 💾 Save Profile
  Future<void> saveProfile() async {

    String userName = username.text.trim().toLowerCase();

    // 🔴 VALIDATION

    if (userName.isEmpty) {
      showMessage("Enter username");
      return;
    }

    if (userName.length < 3) {
      showMessage("Username must be at least 3 characters");
      return;
    }

    if (userName.contains(" ")) {
      showMessage("Username should not contain spaces");
      return;
    }

    if (name.text.trim().isEmpty) {
      showMessage("Enter your name");
      return;
    }

    if (!isValidPhone(phone.text.trim())) {
      showMessage("Enter valid 10-digit phone number");
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      var user = FirebaseAuth.instance.currentUser;

      // 🔥 Check username uniqueness
      bool taken = await isUsernameTaken(userName);

      if (taken) {
        showMessage("Username already taken");
        setState(() => loading = false);
        return;
      }

      // ☁️ Upload image
      String imageUrl = await uploadImage(user!.uid);

      // 💾 Save data
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "uid": user.uid,
        "username": userName,
        "name": name.text.trim(),
        "bio": bio.text.trim(),
        "phone": phone.text.trim(),
        "profileImage": imageUrl,
        "email": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // 🚀 Go to MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );

    } catch (e) {
      showMessage("Something went wrong");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
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
              "Setup Profile",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // 📸 Profile Image
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[800],
                backgroundImage:
                    image != null ? FileImage(image!) : null,
                child: image == null
                    ? const Icon(Icons.add_a_photo, color: Colors.white)
                    : null,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: username,
              style: const TextStyle(color: Colors.white),
              decoration: inputStyle("Username"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: name,
              style: const TextStyle(color: Colors.white),
              decoration: inputStyle("Name"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phone,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: inputStyle("Phone Number"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: bio,
              style: const TextStyle(color: Colors.white),
              decoration: inputStyle("Bio"),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 45,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),

                onPressed: loading ? null : saveProfile,

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}