import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void openMaps(String location) async {
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
    String imageUrl = postData['imageUrl'] ?? "";
    String description = postData['description'] ?? "";
    String title = postData['productName'] ?? postData['jobTitle'] ?? "Post";
    String userName = postData['userName'] ?? "User";
    String userImage = postData['userProfileImage'] ?? "";
    String location = postData['location'] ?? "";

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
                children: [
                  Icon(Icons.favorite_border, color: Colors.white, size: 28),
                  SizedBox(width: 18),
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 26,
                  ),
                  SizedBox(width: 18),
                  Icon(Icons.call, color: Colors.white, size: 26),
                  SizedBox(width: 18),
                  IconButton(
                    onPressed: () => openMaps(location),
                    icon: const Icon(Icons.location_on,
                        color: Colors.white, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () => openMaps(location),
                  child: Text(
                    "📍 $location",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
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

