import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'jobs_feed.dart';
import 'products_feed.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,

        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,

          // 🔥 Center title
          centerTitle: true,

          // 🔥 Remove shadow + white line
          elevation: 0,
          surfaceTintColor: Colors.transparent,

          // 🔥 Reduce vertical space
          toolbarHeight: 50,

          // 🔥 Premium title
          title: Text(
            "Jobo",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),

          // 🔥 Twitter-style TabBar
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              // 🔥 Twitter indicator (short centered line)
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3,
                  color: Color(0xFF3797EF),
                ),
                insets: EdgeInsets.symmetric(horizontal: 40),
              ),

              indicatorSize: TabBarIndicatorSize.tab,

              // 🔥 Clean text colors
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFFA8A8A8),

              // 🔥 Softer typography
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: 0.3,
              ),

              unselectedLabelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),

              tabs: const [
                Tab(text: "Jobs"),
                Tab(text: "Products"),
              ],
            ),
          ),
        ),

        body: const TabBarView(
          children: [
            JobsFeed(),
            ProductsFeed(),
          ],
        ),
      ),
    );
  }
}