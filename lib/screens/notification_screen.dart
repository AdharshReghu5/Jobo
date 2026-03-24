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

  Future<void> _handleApplicationDecision(
      String notificationId, Map<String, dynamic> data, String status) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // 1. Update current notification
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'status': status});

      // 2. Send back a notification to the applicant
      final message = status == 'accepted'
          ? "Your application for \"${data['postTitle']}\" has been accepted!"
          : "Your application for \"${data['postTitle']}\" was not accepted.";

      await FirebaseFirestore.instance.collection('notifications').add({
        "toUserId": data['fromUserId'], 
        "fromUserId": currentUser.uid,
        "fromUserName": "System",
        "postTitle": data['postTitle'],
        "type": status == 'accepted' ? 'apply_accepted' : 'apply_declined',
        "message": message,
        "timestamp": FieldValue.serverTimestamp(),
        "isRead": false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Application $status")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _showReviewDialog(String targetUserId, String postTitle) {
    int selectedRating = 5;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Leave a Review", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("How was your experience with \"$postTitle\"?",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reviewController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write your review...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) return;

                await FirebaseFirestore.instance.collection('reviews').add({
                  "fromUserId": currentUser.uid,
                  "toUserId": targetUserId,
                  "postTitle": postTitle,
                  "rating": selectedRating,
                  "review": reviewController.text,
                  "timestamp": FieldValue.serverTimestamp(),
                });

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Review submitted!")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
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
                      final notificationId = doc.id;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final timeStr = timestamp != null
                          ? DateFormat('MMM d, h:mm a')
                              .format(timestamp.toDate())
                          : "";

                      String message = data['message'] ?? "";
                      IconData icon;
                      Color iconColor;
                      String status = data['status'] ?? "";

                      if (data['type'] == 'apply') {
                        message = message.isEmpty
                            ? "${data['fromUserName']} applied for your job \"${data['postTitle']}\""
                            : message;
                        icon = Icons.work_outline;
                        iconColor = Colors.blue;
                      } else if (data['type'] == 'apply_accepted') {
                        message = message.isEmpty
                            ? "Your application for \"${data['postTitle']}\" was accepted!"
                            : message;
                        icon = Icons.check_circle_outline;
                        iconColor = Colors.green;
                      } else if (data['type'] == 'apply_declined') {
                        message = message.isEmpty
                            ? "Your application for \"${data['postTitle']}\" was declined."
                            : message;
                        icon = Icons.cancel_outlined;
                        iconColor = Colors.red;
                      } else {
                        message = message.isEmpty
                            ? "${data['fromUserName']} wants to buy your product \"${data['postTitle']}\""
                            : message;
                        icon = Icons.shopping_bag_outlined;
                        iconColor = Colors.green;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          ),
                          
                          // Action buttons for job posters
                          if (data['type'] == 'apply' && status.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 70, bottom: 10),
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12)),
                                    onPressed: () => _handleApplicationDecision(
                                        notificationId, data, 'accepted'),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text("Accept"),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12)),
                                    onPressed: () => _handleApplicationDecision(
                                        notificationId, data, 'declined'),
                                    icon: const Icon(Icons.close, size: 16),
                                    label: const Text("Decline"),
                                  ),
                                ],
                              ),
                            ),
                            
                          if (status == 'accepted' && data['type'] == 'apply')
                             const Padding(
                              padding: EdgeInsets.only(left: 70, bottom: 10),
                              child: Text("Status: Accepted", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                            
                          if (status == 'declined' && data['type'] == 'apply')
                             const Padding(
                              padding: EdgeInsets.only(left: 70, bottom: 10),
                              child: Text("Status: Declined", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),

                          // Review button for accepted applicants
                          if (data['type'] == 'apply_accepted')
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 70, bottom: 10),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black),
                                onPressed: () => _showReviewDialog(
                                    data['fromUserId'], data['postTitle']),
                                icon: const Icon(Icons.star, size: 16),
                                label: const Text("Leave Review",
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
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

