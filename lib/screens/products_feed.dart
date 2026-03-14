import 'package:flutter/material.dart';
import '../widgets/product_feed_card.dart';

class ProductsFeed extends StatelessWidget {
  const ProductsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ProductFeedCard(
          seller: "Adharsh",
          productName: "Handmade Wooden Bowl",
          price: "₹500",
          caption: "Made from natural teak wood by local artisans.",
          image: "https://picsum.photos/500/302",
          phone: "918289967871",
        ),

        ProductFeedCard(
          seller: "Shimna",
          productName: "Organic Honey",
          price: "₹350",
          caption: "Pure forest honey collected naturally.",
          image: "https://picsum.photos/500/303",
          phone: "917510659747",
        ),
      ],
    );
  }
}