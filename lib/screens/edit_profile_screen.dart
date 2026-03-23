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

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      username.text = data['username'] ?? "";
      name.text = data['name'] ?? "";
      bio.text = data['bio'] ?? "";
      phone.text = data['phone'] ?? "";
      imageUrl = data['profileImage'] ?? "";
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  Future<String> uploadImage(String uid) async {
    if (image == null) return imageUrl;
    final ref = FirebaseStorage.instance.ref().child("profile_images/$uid.jpg");
    await ref.putFile(image!);
    return await ref.getDownloadURL();
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  Future<bool> isUsernameTaken(String newUsername, String uid) async {
    var result = await FirebaseFirestore.instance.collection("users").get();
    String checkName = newUsername.toLowerCase();

    for (var doc in result.docs) {
      var data = doc.data();
      String existing = (data['username'] ?? "").toString().toLowerCase();
      if (existing == checkName && doc.id != uid) {
        return true;
      }
    }
    return false;
  }

  Future<void> saveProfile() async {
    String newUsername = username.text.trim().toLowerCase();
    if (newUsername.isEmpty) {
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
      bool taken = await isUsernameTaken(newUsername, user!.uid);

      if (taken) {
        if (mounted) {
          setState(() => loading = false);
          showMessage("Username already taken");
        }
        return;
      }

      String newImageUrl = await uploadImage(user.uid);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "username": newUsername,
        "name": name.text.trim(),
        "bio": bio.text.trim(),
        "phone": phone.text.trim(),
        "profileImage": newImageUrl,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showMessage("Update failed");
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

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
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: image != null
                            ? FileImage(image!)
                            : (imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null) as ImageProvider?,
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

