import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobFeedCard extends StatelessWidget {
  final String userName;
  final String profileImage;
  final String jobTitle;
  final String location;
  final String salary;
  final String description;
  final String imageUrl;
  final String phone;
  final String userId;

  const JobFeedCard({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.jobTitle,
    required this.location,
    required this.salary,
    required this.description,
    required this.imageUrl,
    required this.phone,
    required this.userId,
  });

  void call() async {
    final Uri url = Uri.parse("tel:$phone");
    await launchUrl(url);
  }

  void whatsapp() async {
    final Uri url = Uri.parse("https://wa.me/$phone");
    await launchUrl(url);
  }

  void openMaps() async {
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

  void applyJob(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final currentUserName = userDoc.data()?['name'] ?? "Someone";

      await FirebaseFirestore.instance.collection('notifications').add({
        "toUserId": userId,
        "fromUserId": currentUser.uid,
        "fromUserName": currentUserName,
        "postId": jobTitle, 
        "postTitle": jobTitle,
        "type": "apply",
        "timestamp": FieldValue.serverTimestamp(),
        "isRead": false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👤 HEADER
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                child: profileImage.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 10),

              Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),
              const Icon(Icons.more_vert),
            ],
          ),
        ),

        // 🖼 IMAGE (OPTIONAL)
        if (imageUrl.isNotEmpty)
          AspectRatio(
            aspectRatio: 3 / 4, // 🔥 vertical
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        // ⚡ ACTIONS
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Icons.favorite_border),
              const SizedBox(width: 20),

              IconButton(
                onPressed: whatsapp,
                icon: const Icon(Icons.message),
              ),

              IconButton(
                onPressed: call,
                icon: const Icon(Icons.call),
              ),

              IconButton(
                onPressed: openMaps,
                icon: const Icon(Icons.location_on),
              ),
            ],
          ),
        ),

        // 🧰 JOB TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            jobTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 5),

        // 📍 LOCATION + 💰 SALARY
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GestureDetector(
            onTap: openMaps,
            child: Text(
              "📍 $location",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "💰 $salary",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 5),

        // 📝 DESCRIPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(description),
        ),

        // 📝 APPLY BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => applyJob(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Apply Now", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),

        const SizedBox(height: 10),
        Divider(color: Colors.grey[800]),
      ],
    );
  }
}