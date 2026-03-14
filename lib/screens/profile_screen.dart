import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          "adharsh_reghu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.menu),
          SizedBox(width: 12),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 TOP PROFILE SECTION
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      "https://instagram.fcok6-2.fna.fbcdn.net/v/t51.2885-19/504868058_17990879000807084_9064582394234523504_n.jpg?efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby4xMDgwLmMyIn0&_nc_ht=instagram.fcok6-2.fna.fbcdn.net&_nc_cat=108&_nc_oc=Q6cZ2QEKtSuThqiXdXxyJCwZVy4j60-4bHBZ-IeBMLtqDBDUs5LZANxPZitC64360Y5y7KQ&_nc_ohc=R7uH05Ki_nIQ7kNvwFpagYf&_nc_gid=1sQoTVlZ4bkeJIBxJ0ykHw&edm=AP4sbd4BAAAA&ccb=7-5&oh=00_AfmgMEKh8YhuCTnGCOq55oXr8ZM9wl1_zZqht7m6ku9lvw&oe=6959BCBB&_nc_sid=7a9f4b",
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        ProfileStat(count: "12", label: "Posts"),
                        ProfileStat(count: "1.2K", label: "Followers"),
                        ProfileStat(count: "340", label: "Following"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 NAME & BIO
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Adharsh Reghu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Computer Engineer\nAvailable for work",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 EDIT PROFILE BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  side: BorderSide(color: Colors.grey.shade700),
                ),
                onPressed: () {},
                child: const Text("Edit Profile"),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 DIVIDER
            Divider(color: Colors.grey[800]),

            // 🔹 POSTS GRID
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return Container(
                  color: const Color(0xFF1E1E1E),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class ProfileStat extends StatelessWidget {
  final String count;
  final String label;

  const ProfileStat({
    super.key,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
