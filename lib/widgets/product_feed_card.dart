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

  const ProductFeedCard({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.productName,
    required this.price,
    required this.description,
    required this.imageUrl,
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

        const SizedBox(height: 15),
        Divider(color: Colors.grey[800]),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductFeedCard extends StatelessWidget {

  final String seller;
  final String productName;
  final String price;
  final String caption;
  final String image;
  final String phone;
  final VoidCallback? onDelete;

  const ProductFeedCard({
    super.key,
    required this.seller,
    required this.productName,
    required this.price,
    required this.caption,
    required this.image,
    required this.phone,
    this.onDelete,
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
                seller,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                )
              else
                const Icon(Icons.more_vert, color: Colors.white)
            ],
          ),
        ),

        // PRODUCT IMAGE
        Image.network(
          image,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),

        // ACTION BUTTONS
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

        // PRODUCT NAME
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            productName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 4),

        // PRICE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            price,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 6),

        // CAPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            caption,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ),

        const SizedBox(height: 15),
        Divider(color: Colors.grey[800]),
      ],
    );
  }
}