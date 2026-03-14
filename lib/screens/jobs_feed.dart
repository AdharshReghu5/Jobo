import 'package:flutter/material.dart';
import '../widgets/job_feed_card.dart';

class JobsFeed extends StatelessWidget {
  const JobsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        JobFeedCard(
          company: "Adharsh Tech",
          salary: "₹40,000/month",
          description: "Looking for Flutter developer with 1+ year experience",
          image: "https://picsum.photos/500/300",
          phone: "918289967871",
        ),
        JobFeedCard(
          company: "Shimna Solutions",
          salary: "₹35,000/month",
          description: "Hiring UI/UX designer for startup",
          image: "https://picsum.photos/500/301",
          phone: "917510659747",
        ),
      ],
    );
  }
}