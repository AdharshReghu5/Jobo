import 'package:flutter/material.dart';
import 'create_job_post.dart';
import 'create_product_post.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          title: const Text(
            "Create Post",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: "Job"),
              Tab(text: "Product"),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            CreateJobPost(),
            CreateProductPost(),
          ],
        ),
      ),
    );
  }
}