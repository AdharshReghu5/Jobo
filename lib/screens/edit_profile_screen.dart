import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final username = TextEditingController();
  final name = TextEditingController();
  final bio = TextEditingController();
  final phone = TextEditingController();

  File? image;
  String imageUrl = "";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    username.dispose();
    name.dispose();
    bio.dispose();
    phone.dispose();
    super.dispose();
  }

  // 🔥 LOAD USER DATA
  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    final data = doc.data()!;

    username.text = data['username'] ?? "";
    name.text = data['name'] ?? "";
    bio.text = data['bio'] ?? "";
    phone.text = data['phone'] ?? "";
    imageUrl = data['profileImage'] ?? "";

    setState(() {
      loading = false;
    });
  }

  // 📸 PICK IMAGE
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  // ☁️ UPLOAD IMAGE
  Future<String> uploadImage(String uid) async {
    if (image == null) return imageUrl;

    final ref = FirebaseStorage.instance.ref().child("profile_images/$uid.jpg");

    await ref.putFile(image!);
    return await ref.getDownloadURL();
  }

  // 📱 PHONE VALIDATION
  bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  // 💾 SAVE PROFILE
  Future<void> saveProfile() async {
    if (username.text.trim().isEmpty) {
      showMessage("Username required");
      return;
    }

    if (name.text.trim().isEmpty) {
      showMessage("Name required");
      return;
    }

    if (!isValidPhone(phone.text.trim())) {
      showMessage("Enter valid phone number");
      return;
    }

    try {
      setState(() => loading = true);

      final user = FirebaseAuth.instance.currentUser;

      String newImageUrl = await uploadImage(user!.uid);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
            "username": username.text.trim().toLowerCase(),
            "name": name.text.trim(),
            "bio": bio.text.trim(),
            "phone": phone.text.trim(),
            "profileImage": newImageUrl,
          });

      Navigator.pop(context, true); // 🔥 refresh profile
    } catch (e) {
      showMessage("Update failed");
    } finally {
      setState(() => loading = false);
    }
  }

  // 🔔 MESSAGE
  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF080808),

      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: saveProfile,
            child: const Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔥 PROFILE IMAGE
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: image != null
                            ? FileImage(image!)
                            : (imageUrl.isNotEmpty
                                      ? NetworkImage(imageUrl)
                                      : null)
                                  as ImageProvider?,
                        child: (image == null && imageUrl.isEmpty)
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: pickImage,
                      child: const Text(
                        "Change Profile Photo",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),

                    const SizedBox(height: 20),

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
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputStyle("Bio"),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
