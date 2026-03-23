import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductFeedCard extends StatelessWidget {
  final String userName;
  final String profileImage;
  final String productName;
  final String price;
  final String description;
  final String imageUrl;
  final String phone;
  final String location;

  const ProductFeedCard({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.productName,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.phone,
    required this.location,
  });

  void call() async {
    final Uri url = Uri.parse("tel:$phone");
    await launchUrl(url);
  }

  void whatsapp() async {
    final Uri url = Uri.parse("https://wa.me/$phone");
    await launchUrl(url);
  }

  void openMaps() async {
    Uri url;
    if (location.startsWith("http://") || location.startsWith("https://")) {
      url = Uri.parse(location);
    } else {
      url = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}");
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👤 HEADER
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
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
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),
              const Icon(Icons.more_vert),
            ],
          ),
        ),

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
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Icons.favorite_border),
              const SizedBox(width: 20),

              IconButton(
                onPressed: whatsapp,
                icon: const Icon(Icons.message),
              ),

              IconButton(
                onPressed: call,
                icon: const Icon(Icons.call),
              ),

              IconButton(
                onPressed: openMaps,
                icon: const Icon(Icons.location_on),
              ),
            ],
          ),
        ),

        // 📦 PRODUCT NAME
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            productName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 4),

        // 💰 PRICE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "₹ $price",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 6),

        // 📝 DESCRIPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(description),
        ),

        if (location.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: GestureDetector(
              onTap: openMaps,
              child: Text(
                "📍 $location",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        const SizedBox(height: 15),
        Divider(color: Colors.grey[800]),
      ],
    );
  }
}