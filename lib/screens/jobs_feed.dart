import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/job_feed_card.dart';

class JobsFeed extends StatelessWidget {
  const JobsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No jobs yet"));
        }

        final jobs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index].data() as Map<String, dynamic>;

            return JobFeedCard(
              userName: job['userName'] ?? "",
              profileImage: job['userProfileImage'] ?? "",
              jobTitle: job['jobTitle'] ?? "",
              location: job['location'] ?? "",
              salary: job['salary'] ?? "",
              description: job['description'] ?? "",
              imageUrl: job['imageUrl'] ?? "",
              phone: job['phone'] ?? "",
            );
          },
        );
      },
    );
  }
}