import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/product_feed_card.dart';

class ProductsFeed extends StatelessWidget {
  const ProductsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No products yet"));
        }

        final products = snapshot.data!.docs;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index].data() as Map<String, dynamic>;

            return ProductFeedCard(
              userName: product['userName'] ?? "",
              profileImage: product['userProfileImage'] ?? "",
              productName: product['productName'] ?? "",
              price: product['price'] ?? "",
              description: product['description'] ?? "",
              imageUrl: product['imageUrl'] ?? "",
              phone: product['phone'] ?? "",
              location: product['location'] ?? "",
            );
          },
        );
      },
    );
  }
}
