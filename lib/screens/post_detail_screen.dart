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

  Future<void> deletePost(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
        .delete();

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Post deleted")));
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = postData['imageUrl'] ?? "";

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Post"),
                    content: const Text("Are you sure you want to delete?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          deletePost(context);
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text("Delete")),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 IMAGE
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 USER NAME
                  Text(
                    postData['userName'] ?? "User",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🧾 JOB POST
                  if (collection == "jobs") ...[
                    Text(
                      postData['jobTitle'] ?? "",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      "Salary: ${postData['salary']}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      postData['description'] ?? "",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],

                  // 🛍 PRODUCT POST
                  if (collection == "products") ...[
                    Text(
                      postData['productName'] ?? "",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      "₹${postData['price']}",
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(
                      postData['description'] ?? "",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
