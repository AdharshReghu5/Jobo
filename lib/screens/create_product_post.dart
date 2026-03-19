import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateProductPost extends StatefulWidget {
  const CreateProductPost({super.key});

  @override
  State<CreateProductPost> createState() => _CreateProductPostState();
}

class _CreateProductPostState extends State<CreateProductPost> {
  File? image;

  // 🔥 Controllers
  final TextEditingController productNameController =
      TextEditingController();
  final TextEditingController priceController =
      TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  // 🖼 Pick Image
  Future pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);

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

  // ☁️ Upload Image (NOW WORKS)
  Future<String> uploadImage(File image) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images')
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Product"),
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

            // 📦 PRODUCT NAME
            TextField(
              controller: productNameController,
              decoration: inputStyle(context, "Product Name"),
            ),

            const SizedBox(height: 12),

            // 💰 PRICE
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: inputStyle(context, "Price"),
            ),

            const SizedBox(height: 12),

            // 📝 DESCRIPTION
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: inputStyle(context, "Description"),
            ),

            const SizedBox(height: 25),

            // 🔵 POST BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final productName =
                      productNameController.text.trim();
                  final price = priceController.text.trim();
                  final description =
                      descriptionController.text.trim();

                  if (productName.isEmpty ||
                      price.isEmpty ||
                      description.isEmpty) {
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

                    // 🔥 GET USER DATA
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    final userData = userDoc.data();

                    final phone = userData?['phone'] ?? "";
                    final userName = userData?['name'] ?? "User";
                    final profileImage =
                        userData?['profileImage'] ?? "";

                    // 🖼 OPTIONAL IMAGE
                    String imageUrl = "";
                    if (image != null) {
                      imageUrl = await uploadImage(image!);
                    }

                    // 📦 SAVE PRODUCT
                    await FirebaseFirestore.instance
                        .collection('products')
                        .add({
                      "userId": user.uid,
                      "userName": userName,
                      "userProfileImage": profileImage,
                      "phone": phone,

                      "productName": productName,
                      "price": price,
                      "description": description,
                      "imageUrl": imageUrl,

                      "createdAt":
                          FieldValue.serverTimestamp(),
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Product Posted Successfully")),
                    );

                    // 🔄 CLEAR
                    productNameController.clear();
                    priceController.clear();
                    descriptionController.clear();

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
                  "Post Product",
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