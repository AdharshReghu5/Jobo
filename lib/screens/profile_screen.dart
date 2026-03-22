import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'create_job_post.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<DocumentSnapshot> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection("users").doc(user!.uid).get();
  }

  Widget postCountWidget() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, jobSnap) {
        if (!jobSnap.hasData) return const Text("0");

        int jobCount = jobSnap.data!.docs
            .where((doc) => doc['userId'] == uid)
            .length;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, productSnap) {
            if (!productSnap.hasData) return Text("$jobCount");

            int productCount = productSnap.data!.docs
                .where((doc) => doc['userId'] == uid)
                .length;

            return Text(
              "${jobCount + productCount}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            );
          },
        );
      },
    );
  }

  Widget buildUserPosts() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, jobSnap) {
        if (!jobSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var jobPosts = jobSnap.data!.docs
            .where((doc) => doc['userId'] == uid)
            .toList();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, productSnap) {
            if (!productSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var productPosts = productSnap.data!.docs
                .where((doc) => doc['userId'] == uid)
                .toList();

            var allPosts = [...jobPosts, ...productPosts];

            if (allPosts.isEmpty) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.photo_camera,
                        size: 70,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "No Posts Yet",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateJobPost(),
                            ),
                          );
                        },
                        child: const Text("Create Post"),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GridView.builder(
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
                  child: Image.network(
                    post['imageUrl'] ?? "",
                    fit: BoxFit.cover,
                  ),
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
    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        String name = data['name'] ?? "";
        String username = data['username'] ?? ""; // 🔥 THIS IS NEW
        String bio = data['bio'] ?? "";
        String image = data['profileImage'] ?? "";

        return Scaffold(
          backgroundColor: Colors.black,

          // 🔥 USERNAME AT TOP (FIXED)
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () async {
                  String? value = await showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                    items: const [
                      PopupMenuItem(value: "edit", child: Text("Edit Profile")),
                      PopupMenuItem(value: "logout", child: Text("Logout")),
                    ],
                  );

                  if (value == "edit") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  } else if (value == "logout") {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
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
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: image.isNotEmpty
                            ? NetworkImage(image)
                            : null,
                        child: image.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                postCountWidget(),
                                const Text(
                                  "Posts",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            const Column(
                              children: [
                                Text(
                                  "0",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Followers",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            const Column(
                              children: [
                                Text(
                                  "0",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Following",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (bio.isNotEmpty)
                        Text(
                          bio,
                          style: const TextStyle(color: Colors.white70),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.grey),
                buildUserPosts(),
              ],
            ),
          ),
        );
      },
    );
  }
}
