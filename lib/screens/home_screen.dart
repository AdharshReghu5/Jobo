import 'package:flutter/material.dart';
import 'jobs_feed.dart';
import 'products_feed.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          title: const Text("Jobo"),
         bottom: const TabBar(
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.white,
          tabs: [
            Tab(text: "Jobs"),
            Tab(text: "Products"),
          ],
),
        ),
        body: const TabBarView(
          children: [
            JobsFeed(),
            ProductsFeed(),
          ],
        ),
      ),
    );
  }
}