import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/job_feed_card.dart';
import '../widgets/product_feed_card.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _deleteDocument(BuildContext context, String collection, String docId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this post?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully.')),
        );
      }
    }
  }

  Widget _buildJobsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No jobs found.', style: TextStyle(color: Colors.white)),
          );
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                    Image.network(data['imageUrl'])
                  else if (data['image'] != null && data['image'].toString().isNotEmpty)
                    Image.network(data['image']), // Fallback support for older schema
                  
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      data['description'] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  // 🔥 DELETE BUTTON
                  TextButton(
                    onPressed: () => _deleteDocument(context, 'jobs', docId),
                    child: const Text(
                      "Delete Post",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No products found.', style: TextStyle(color: Colors.white)),
          );
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                    Image.network(data['imageUrl'])
                  else if (data['image'] != null && data['image'].toString().isNotEmpty)
                    Image.network(data['image']), // Fallback support for older schema
                  
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      data['description'] ?? data['caption'] ?? "No description",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  // 🔥 DELETE BUTTON
                  TextButton(
                    onPressed: () => _deleteDocument(context, 'products', docId),
                    child: const Text(
                      "Delete Post",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
            )
          ],
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Jobs"),
              Tab(text: "Products"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildJobsTab(),
            _buildProductsTab(),
          ],
        ),
      ),
    );
  }
}
