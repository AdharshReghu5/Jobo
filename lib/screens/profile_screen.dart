import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'package:jobo/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance.collection("users").doc(user!.uid).get();
  }

  // 🔥 REFRESH FUNCTION
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("...");
            }

            String username = snapshot.data!['username'] ?? "";

            return Text(
              username.isEmpty ? "profile" : username,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            );
          },
        ),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),

            onSelected: (value) async {
              // 🔥 EDIT PROFILE FROM MENU
              if (value == "edit") {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );

                if (updated == true) {
                  refresh();
                }
              }
              // 🔥 LOGOUT
              else if (value == "logout") {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
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

      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!;

          String username = data['username'] ?? "";
          String name = data['name'] ?? "";
          String bio = data['bio'] ?? "";
          String imageUrl = data['profileImage'] ?? "";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 🔥 PROFILE ROW
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: theme.dividerColor,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),

                      const SizedBox(width: 25),

                      const Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ProfileStat(count: "0", label: "Posts"),
                            ProfileStat(count: "0", label: "Followers"),
                            ProfileStat(count: "0", label: "Following"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 🔥 NAME + BIO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // 🔥 USERNAME (optional nice UI)
                      Text(
                        "@$username",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 4),

                      if (bio.isNotEmpty)
                        Text(
                          bio,
                          style: const TextStyle(color: Color(0xFFA8A8A8)),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 🔥 EDIT PROFILE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: SizedBox(
                    width: double.infinity,
                    height: 36,

                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3797EF)),
                        foregroundColor: const Color(0xFF3797EF),
                      ),

                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );

                        if (updated == true) {
                          refresh();
                        }
                      },

                      child: const Text("Edit Profile"),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Divider(color: theme.dividerColor),

                // 🔥 GRID
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
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFA8A8A8),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFA8A8A8), fontSize: 13),
        ),
      ],
    );
  }
}
