import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobFeedCard extends StatelessWidget {
<<<<<<< HEAD
  final String userName;
  final String profileImage;
  final String jobTitle;
  final String location;
  final String salary;
  final String description;
  final String imageUrl;
  final String phone;

  const JobFeedCard({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.jobTitle,
    required this.location,
    required this.salary,
    required this.description,
    required this.imageUrl,
    required this.phone,
=======

  final String company;
  final String salary;
  final String description;
  final String image;
  final String phone;
  final VoidCallback? onDelete;

  const JobFeedCard({
    super.key,
    required this.company,
    required this.salary,
    required this.description,
    required this.image,
    required this.phone,
    this.onDelete,
>>>>>>> 9990131 (hi)
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
<<<<<<< HEAD
=======

>>>>>>> 9990131 (hi)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

<<<<<<< HEAD
        // 👤 HEADER
=======
        // HEADER
>>>>>>> 9990131 (hi)
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
<<<<<<< HEAD
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                child: profileImage.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 10),

              Text(
                userName,
                style: const TextStyle(
=======

              const CircleAvatar(radius: 18),
              const SizedBox(width: 10),

              Text(
                company,
                style: const TextStyle(
                  color: Colors.white,
>>>>>>> 9990131 (hi)
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),
<<<<<<< HEAD
              const Icon(Icons.more_vert),
=======

              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                )
              else
                const Icon(Icons.more_vert, color: Colors.white)

>>>>>>> 9990131 (hi)
            ],
          ),
        ),

<<<<<<< HEAD
        // 🖼 IMAGE (OPTIONAL)
        if (imageUrl.isNotEmpty)
          AspectRatio(
            aspectRatio: 3 / 4, // 🔥 vertical
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        // ⚡ ACTIONS
=======
        // IMAGE
        Image.network(
          image,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),

        // ACTIONS
>>>>>>> 9990131 (hi)
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
<<<<<<< HEAD
              const Icon(Icons.favorite_border),
=======

              const Icon(Icons.favorite_border, color: Colors.white),
>>>>>>> 9990131 (hi)
              const SizedBox(width: 20),

              IconButton(
                onPressed: whatsapp,
<<<<<<< HEAD
                icon: const Icon(Icons.message),
=======
                icon: const Icon(Icons.message, color: Colors.white),
>>>>>>> 9990131 (hi)
              ),

              IconButton(
                onPressed: call,
<<<<<<< HEAD
                icon: const Icon(Icons.call),
=======
                icon: const Icon(Icons.call, color: Colors.white),
>>>>>>> 9990131 (hi)
              ),
            ],
          ),
        ),

<<<<<<< HEAD
        // 🧰 JOB TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            jobTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
=======
        // SALARY
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            salary,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
>>>>>>> 9990131 (hi)
            ),
          ),
        ),

        const SizedBox(height: 5),

<<<<<<< HEAD
        // 📍 LOCATION + 💰 SALARY
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text("📍 $location"),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "💰 $salary",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 5),

        // 📝 DESCRIPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(description),
        ),

=======
        // DESCRIPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            description,
            style: const TextStyle(color: Colors.white70),
          ),
        ),

>>>>>>> 9990131 (hi)
        const SizedBox(height: 15),
        Divider(color: Colors.grey[800]),
      ],
    );
  }
}