import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String bio = "";
  String joboId = "";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        name = doc['name'] ?? "";
        bio = doc['bio'] ?? "";
        joboId = doc['joboId'] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        title: Text(
          joboId.isEmpty ? "profile" : "@$joboId",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),

            onSelected: (value) async {
              if (value == "logout") {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(value: "edit", child: Text("Edit Profile")),

              const PopupMenuItem(value: "settings", child: Text("Settings")),

              const PopupMenuDivider(),

              const PopupMenuItem(
                value: "logout",
                child: Text("Log Out", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.grey),

                  const SizedBox(width: 25),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        ProfileStat(count: "12", label: "Posts"),

                        ProfileStat(count: "1.2K", label: "Followers"),

                        ProfileStat(count: "340", label: "Following"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? "Loading..." : name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    joboId.isEmpty ? "" : "@$joboId",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 4),

                  if (bio.isNotEmpty)
                    Text(
                      bio,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: SizedBox(
                width: double.infinity,
                height: 36,

                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade700),
                  ),

                  onPressed: () {},

                  child: const Text("Edit Profile"),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Divider(color: Colors.grey[800]),

            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              itemCount: 12,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),

              itemBuilder: (context, index) {
                return Container(
                  color: const Color(0xFF1E1E1E),

                  child: const Icon(Icons.image_outlined, color: Colors.grey),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String count;
  final String label;

  const ProfileStat({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 4),

        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
