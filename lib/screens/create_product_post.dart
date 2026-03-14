import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateProductPost extends StatefulWidget {
  const CreateProductPost({super.key});

  @override
  State<CreateProductPost> createState() => _CreateProductPostState();
}

class _CreateProductPostState extends State<CreateProductPost> {

  File? image;

  Future pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
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
      backgroundColor: Colors.black,

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 40),

              const Text(
                "Create Product",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: image == null
                      ? const Icon(Icons.add_a_photo,
                          color: Colors.white, size: 40)
                      : Image.file(image!, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                decoration: inputStyle("Seller Name"),
              ),

              const SizedBox(height: 15),

              TextField(
                decoration: inputStyle("Product Name"),
              ),

              const SizedBox(height: 15),

              TextField(
                decoration: inputStyle("Price"),
              ),

              const SizedBox(height: 15),

              TextField(
                decoration: inputStyle("Caption"),
              ),

              const SizedBox(height: 15),

              TextField(
                decoration: inputStyle("Phone Number"),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {},
                child: const Text("Post Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}