import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobo/widgets/product_feed_card.dart';
import 'package:jobo/widgets/job_feed_card.dart';
import 'package:jobo/screens/post_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _jobs = [];
  List<DocumentSnapshot> _products = [];
  List<DocumentSnapshot> _users = [];
  List<Map<String, dynamic>> _filteredResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final jobsSnap =
          await FirebaseFirestore.instance.collection('jobs').get();
      final productsSnap =
          await FirebaseFirestore.instance.collection('products').get();
      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        _jobs = jobsSnap.docs;
        _products = productsSnap.docs;
        _users = usersSnap.docs;
        _isLoading = false;
        _performSearch(""); // Initial empty search
      });
    } catch (e) {
      debugPrint("Error fetching search data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredResults = [];
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    List<Map<String, dynamic>> results = [];

    // Search Category: Jobs
    for (var doc in _jobs) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['jobTitle'] ?? "").toString().toLowerCase();
      final user = (data['userName'] ?? "").toString().toLowerCase();
      final loc = (data['location'] ?? "").toString().toLowerCase();

      if (title.contains(lowercaseQuery) ||
          user.contains(lowercaseQuery) ||
          loc.contains(lowercaseQuery)) {
        results.add({
          'type': 'job',
          'data': data,
          'id': doc.id,
        });
      }
    }

    // Search Category: Products
    for (var doc in _products) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['productName'] ?? "").toString().toLowerCase();
      final user = (data['userName'] ?? "").toString().toLowerCase();
      final loc = (data['location'] ?? "").toString().toLowerCase();

      if (name.contains(lowercaseQuery) ||
          user.contains(lowercaseQuery) ||
          loc.contains(lowercaseQuery)) {
        results.add({
          'type': 'product',
          'data': data,
          'id': doc.id,
        });
      }
    }

    // Search Category: Users (Optional UI, but including data)
    for (var doc in _users) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['name'] ?? "").toString().toLowerCase();
      if (name.contains(lowercaseQuery)) {
        // Only add if not already represented in a post (simple rule for now)
        bool alreadyExists = results.any((r) => r['data']['userName'] == data['name']);
        if (!alreadyExists) {
            results.add({
                'type': 'user',
                'data': data,
                'id': doc.id,
            });
        }
      }
    }

    setState(() {
      _filteredResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        elevation: 0,
        title: TextField(
          controller: _searchController,
          onChanged: _performSearch,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search Jobs, Users, or Locations",
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredResults.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? "Start typing to search"
                        : "No results found",
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredResults.length,
                  itemBuilder: (context, index) {
                    final item = _filteredResults[index];
                    final data = item['data'];
                    final id = item['id'];

                    if (item['type'] == 'job') {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(
                              postId: id,
                              postData: data,
                              collection: 'jobs',
                            ),
                          ),
                        ),
                        child: JobFeedCard(
                          jobTitle: data['jobTitle'] ?? "",
                          userName: data['userName'] ?? "User",
                          location: data['location'] ?? "",
                          salary: data['salary'] ?? "",
                          description: data['description'] ?? "",
                          imageUrl: data['imageUrl'] ?? "",
                          profileImage: data['userProfileImage'] ?? "",
                          phone: data['phone'] ?? "",
                          userId: data['userId'] ?? "",
                        ),
                      );
                    } else if (item['type'] == 'product') {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(
                              postId: id,
                              postData: data,
                              collection: 'products',
                            ),
                          ),
                        ),
                        child: ProductFeedCard(
                          productName: data['productName'] ?? "",
                          userName: data['userName'] ?? "User",
                          price: data['price'] ?? "",
                          description: data['description'] ?? "",
                          imageUrl: data['imageUrl'] ?? "",
                          phone: data['phone'] ?? "",
                          profileImage: data['userProfileImage'] ?? "",
                          userId: data['userId'] ?? "",
                        ),
                      );
                    } else {
                      // Profile display
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: data['profileImage'] != null
                              ? NetworkImage(data['profileImage'])
                              : null,
                          child: data['profileImage'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          data['name'] ?? "User",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          data['jobTitle'] ?? "No profession listed",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                  },
                ),
    );
  }
}

