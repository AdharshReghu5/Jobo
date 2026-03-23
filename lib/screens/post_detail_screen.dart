import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> postData;
  final String collection;

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.postData,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = postData['imageUrl'] ?? "";
    String description = postData['description'] ?? "";
    String title = postData['productName'] ?? postData['jobTitle'] ?? "Post";
    String userName = postData['userName'] ?? "User";
    String userImage = postData['userProfileImage'] ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: userImage.isNotEmpty
                        ? NetworkImage(userImage)
                        : null,
                    child: userImage.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) async {
                      if (value == "delete") {
                        await FirebaseFirestore.instance
                            .collection(collection)
                            .doc(postId)
                            .delete();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "delete",
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: const [
                  Icon(Icons.favorite_border, color: Colors.white, size: 28),
                  SizedBox(width: 18),
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 26,
                  ),
                  SizedBox(width: 18),
                  Icon(Icons.call, color: Colors.white, size: 26),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                description,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

