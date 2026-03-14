import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobFeedCard extends StatelessWidget {

  final String company;
  final String salary;
  final String description;
  final String image;
  final String phone;

  const JobFeedCard({
    super.key,
    required this.company,
    required this.salary,
    required this.description,
    required this.image,
    required this.phone,
  });

  void call() async {
    final Uri url = Uri.parse("tel:$phone");
    await launchUrl(url);
  }

  void whatsapp() async {
    final Uri url = Uri.parse("https://wa.me/$phone");
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // HEADER
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [

              const CircleAvatar(radius: 18),
              const SizedBox(width: 10),

              Text(
                company,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              const Icon(Icons.more_vert, color: Colors.white)

            ],
          ),
        ),

        // IMAGE
        Image.network(
          image,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),

        // ACTIONS
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [

              const Icon(Icons.favorite_border, color: Colors.white),
              const SizedBox(width: 20),

              IconButton(
                onPressed: whatsapp,
                icon: const Icon(Icons.message, color: Colors.white),
              ),

              IconButton(
                onPressed: call,
                icon: const Icon(Icons.call, color: Colors.white),
              ),
            ],
          ),
        ),

        // SALARY
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            salary,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 5),

        // DESCRIPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            description,
            style: const TextStyle(color: Colors.white70),
          ),
        ),

        const SizedBox(height: 15),
        Divider(color: Colors.grey[800]),
      ],
    );
  }
}