import 'package:flutter/material.dart';
import 'package:jobo/screens/home_screen.dart';
import 'package:jobo/screens/search_screen.dart';
import 'package:jobo/screens/create_post_screen.dart';
import 'package:jobo/screens/notification_screen.dart';
import 'package:jobo/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final pages = [
    const HomeScreen(),
    const SearchScreen(),
    const CreatePostScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search, size: 30), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 32), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined, size: 30), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle, size: 30), label: ""),
        ],
      ),
    );
  }
}
