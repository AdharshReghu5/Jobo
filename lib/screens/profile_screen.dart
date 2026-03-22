import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'package:jobo/screens/edit_profile_screen.dart';
import 'package:jobo/screens/create_job_post.dart';
import 'post_detail_screen.dart';

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

  void refresh() {
    setState(() {});
  }

  // 🔥 POST COUNT
  Widget postCountWidget() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, jobSnap) {
        if (!jobSnap.hasData) {
          return const ProfileStat(count: "0", label: "Posts");
        }

        int jobCount = jobSnap.data!.docs
            .where((doc) => doc['userId'] == uid)
            .length;

        return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, productSnap) {
            if (!productSnap.hasData) {
              return ProfileStat(count: "$jobCount", label: "Posts");
            }

            int productCount = productSnap.data!.docs
                .where((doc) => doc['userId'] == uid)
                .length;

            return ProfileStat(
              count: "${jobCount + productCount}",
              label: "Posts",
            );
          },
        );
      },
    );
  }

  // 🔥 USER POSTS GRID
  Widget buildUserPosts() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, jobSnap) {
        if (!jobSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobPosts = jobSnap.data!.docs
            .where((doc) => doc['userId'] == uid)
            .toList();

        return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, productSnap) {
            if (!productSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var productPosts = productSnap.data!.docs
                .where((doc) => doc['userId'] == uid)
                .toList();

            var allPosts = [...jobPosts, ...productPosts];

            // ❌ NO POSTS
            if (allPosts.isEmpty) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.photo_camera,
                        size: 70,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No Posts Yet",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateJobPost(),
                            ),
                          );
                          refresh();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Create Post"),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✅ GRID
            return GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allPosts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                var doc = allPosts[index];
                var post = doc.data() as Map<String, dynamic>;

                String imageUrl = post['imageUrl'] ?? "";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(
                          postId: doc.id,
                          postData: post,
                          collection: post.containsKey('productName')
                              ? 'products'
                              : 'jobs',
                        ),
                      ),
                    );
                  },
                  child: imageUrl.isEmpty
                      ? Container(color: Colors.grey)
                      : Image.network(imageUrl, fit: BoxFit.cover),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) async {
              if (value == "edit") {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                refresh();
              } else if (value == "logout") {
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
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: "logout",
                child: Text("Log Out", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),

      body: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!;
          String name = data['name'] ?? "";
          String bio = data['bio'] ?? "";
          String imageUrl = data['profileImage'] ?? "";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // PROFILE ROW
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 25),

                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            postCountWidget(),
                            const ProfileStat(count: "0", label: "Followers"),
                            const ProfileStat(count: "0", label: "Following"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // NAME + BIO (username removed)
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
                      if (bio.isNotEmpty)
                        Text(
                          bio,
                          style: const TextStyle(color: Color(0xFFA8A8A8)),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 🔥 EDIT BUTTON (Instagram style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                        refresh();
                      },
                      child: const Text("Edit Profile"),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Divider(color: theme.dividerColor),

                buildUserPosts(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🔥 STAT
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
