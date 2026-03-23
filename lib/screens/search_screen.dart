import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        elevation: 0,
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(height: 10),
        ),
      ),
      body: ListView(
        children: [
          searchResult("Nived", "Entrepreneur"),
          searchResult("Shimna", "Photographer"),
        ],
      ),
    );
  }

  Widget searchResult(String name, String profession) {
    return Column(
      children: [
        ListTile(
          leading: const CircleAvatar(radius: 25),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(
            profession,
            style: const TextStyle(
              color: Color.fromARGB(255, 155, 155, 155),
              fontSize: 14,
            ),
          ),
          trailing: const Icon(Icons.close, size: 20),
        ),
        Divider(
          color: Colors.grey[800],
          indent: 72,
          endIndent: 12,
        ),
      ],
    );
  }
}

