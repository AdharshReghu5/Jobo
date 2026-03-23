import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateJobPost extends StatefulWidget {
  const CreateJobPost({super.key});

  @override
  State<CreateJobPost> createState() => _CreateJobPostState();
}

class _CreateJobPostState extends State<CreateJobPost> {
  File? image;

  // 🔥 Controllers
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // 🖼 Pick Image
  Future pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);

    // 📏 FILE SIZE LIMIT (5MB)
    final fileSize = await file.length();
    if (fileSize > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image must be less than 5MB")),
      );
      return;
    }

    setState(() {
      image = file;
    });
  }

  // ☁️ Upload Image
  Future<String> uploadImage(File image) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child('job_images')
        .child('$uid-${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  // 🎨 Input style
  InputDecoration inputStyle(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  void openMapsPreview() async {
    final location = locationController.text.trim();
    if (location.isEmpty) return;

    Uri url;
    if (location.startsWith("http://") || location.startsWith("https://")) {
      url = Uri.parse(location);
    } else {
      url = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}");
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Job"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🖼 IMAGE (OPTIONAL)
            GestureDetector(
              onTap: pickImage,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: image == null
                      ? Icon(Icons.add_a_photo,
                          color: Colors.grey[400], size: 40)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🧰 JOB TITLE
            TextField(
              controller: jobTitleController,
              decoration: inputStyle(context, "Job Title"),
            ),

            const SizedBox(height: 12),

            // 📍 LOCATION
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationController,
                    decoration: inputStyle(
                        context, "Location URL (Google Maps Link)"),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: openMapsPreview,
                  icon: const Icon(Icons.map, color: Colors.blue),
                  tooltip: "See on Map",
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 💰 SALARY
            TextField(
              controller: salaryController,
              keyboardType: TextInputType.number,
              decoration: inputStyle(context, "Salary"),
            ),

            const SizedBox(height: 12),

            // 📝 DESCRIPTION
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: inputStyle(context, "Job Description"),
            ),

            const SizedBox(height: 25),

            // 🔵 POST BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final jobTitle = jobTitleController.text.trim();
                  final salary = salaryController.text.trim();
                  final description =
                      descriptionController.text.trim();
                  final location = locationController.text.trim();

                  // 🔴 VALIDATION (no image, no phone)
                  if (jobTitle.isEmpty ||
                      salary.isEmpty ||
                      description.isEmpty ||
                      location.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  try {
                    // 🔄 LOADING
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(
                          child: CircularProgressIndicator()),
                    );

                    final user =
                        FirebaseAuth.instance.currentUser!;

                    // 🔥 GET USER DATA FROM FIRESTORE
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    final userData = userDoc.data();

                    final phone = userData?['phone'] ?? "";
                    final userName = userData?['name'] ?? "User";
                    final profileImage =
                        userData?['profileImage'] ?? "";

                    // 🖼 OPTIONAL IMAGE UPLOAD
                    String imageUrl = "";
                    if (image != null) {
                      imageUrl = await uploadImage(image!);
                    }

                    // 📦 SAVE JOB
                    await FirebaseFirestore.instance
                        .collection('jobs')
                        .add({
                      "userId": user.uid,
                      "userName": userName,
                      "userProfileImage": profileImage,
                      "phone": phone,

                      "jobTitle": jobTitle,
                      "salary": salary,
                      "description": description,
                      "location": location,
                      "imageUrl": imageUrl,

                      "createdAt":
                          FieldValue.serverTimestamp(),
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Job Posted Successfully")),
                    );

                    // 🔄 CLEAR
                    jobTitleController.clear();
                    salaryController.clear();
                    descriptionController.clear();
                    locationController.clear();

                    setState(() {
                      image = null;
                    });

                  } catch (e) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3797EF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Post Job",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}