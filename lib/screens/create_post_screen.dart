import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobo/screens/create_job_post.dart';
import 'package:jobo/screens/create_product_post.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
          title: Text(
            "New post",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3,
                  color: Color(0xFF3797EF),
                ),
                insets: EdgeInsets.symmetric(horizontal: 40),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFFA8A8A8),
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
                Tab(text: "Job"),
                Tab(text: "Product"),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            CreateJobPost(),
            CreateProductPost(),
          ],
        ),
      ),
    );
  }
}