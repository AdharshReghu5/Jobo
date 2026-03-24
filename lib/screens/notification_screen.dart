import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Stream<QuerySnapshot>? _notificationsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _notificationsStream = FirebaseFirestore.instance
          .collection('notifications')
          .where('toUserId', isEqualTo: user.uid)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: user == null
          ? const Center(child: Text("Please log in to see notifications"))
          : StreamBuilder<QuerySnapshot>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  // Get docs and sort them client-side to avoid index requirement
                  final docs = List.from(snapshot.data!.docs);
                  docs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['timestamp'] as Timestamp?;
                    final bTime = bData['timestamp'] as Timestamp?;
                    
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    
                    return bTime.compareTo(aTime); // Descending sort
                  });

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final timeStr = timestamp != null
                          ? DateFormat('MMM d, h:mm a')
                              .format(timestamp.toDate())
                          : "";

                      String message = "";
                      IconData icon;
                      Color iconColor;

                      if (data['type'] == 'apply') {
                        message =
                            "${data['fromUserName']} applied for your job \"${data['postTitle']}\"";
                        icon = Icons.work_outline;
                        iconColor = Colors.blue;
                      } else {
                        message =
                            "${data['fromUserName']} wants to buy your product \"${data['postTitle']}\"";
                        icon = Icons.shopping_bag_outlined;
                        iconColor = Colors.green;
                      }

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: iconColor.withOpacity(0.1),
                              child: Icon(icon, color: iconColor),
                            ),
                            title: Text(
                              message,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                            subtitle: Text(
                              timeStr,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            onTap: () {
                              // Mark as read or navigate? For now just UI.
                            },
                          ),
                          Divider(color: Colors.grey[900], indent: 70),
                        ],
                      );
                    },
                  );
                }

                // Show empty state only when active and truly empty
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.hasData) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No notifications yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }
}

