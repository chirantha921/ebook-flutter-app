import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart'; // Make sure your constants.dart is correctly imported

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isEmpty = false; // Toggle this to see empty or full state

  // Sample notification data
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Security Updates!",
      "date": "Today | 09:24 AM",
      "description":
          "Now Erabook has a Two-Factor Authentication. Try it now to make your account more secure.",
      "iconColor": Color(0xFF4C9AFF),
      "isNew": true,
    },
    {
      "title": "Multiple Card Features!",
      "date": "1 day ago | 14:43 PM",
      "description":
          "Now you can also connect Erabook with multiple MasterCard & Visa. Try the service now.",
      "iconColor": Color(0xFFFFB840),
      "isNew": true,
    },
    {
      "title": "New Updates Available!",
      "date": "2 days ago | 10:29 AM",
      "description":
          "Update Erabook now to get access to the latest features for easier in buying ebook.",
      "iconColor": Color(0xFF4C9AFF),
      "isNew": false,
    },
    {
      "title": "Your Storage is Almost Full!",
      "date": "5 days ago | 16:52 PM",
      "description":
          "Your storage is almost full. Delete some items to make more space.",
      "iconColor": Color(0xFFFF5C5C),
      "isNew": false,
    },
    {
      "title": "Credit Card Connected!",
      "date": "6 days ago | 15:38 PM",
      "description":
          "Your credit card has been successfully linked with Erabook. Enjoy our services.",
      "iconColor": Color(0xFF7B61FF),
      "isNew": false,
    },
    {
      "title": "Account Setup Successful!",
      "date": "12 Dec, 2022 | 14:27 PM",
      "description":
          "Your account creation is successful, you can now experience our services.",
      "iconColor": Color(0xFF34C759),
      "isNew": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Customize based on your app's style
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Notification',
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.black87,
            onPressed: () {},
          ),
        ],
      ),
      body: isEmpty ? _buildEmptyState() : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your empty-state illustration asset
            // Ensure you've added the asset in pubspec.yaml
            Image.asset(
              'assets/images/empty_clipboards.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              'Empty',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any notification at this time",
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return _buildNotificationItem(
          title: notif["title"],
          date: notif["date"],
          description: notif["description"],
          iconColor: notif["iconColor"],
          isNew: notif["isNew"],
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String date,
    required String description,
    required Color iconColor,
    required bool isNew,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle with icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            // This could be replaced with a specific icon or an image
            child: Icon(
              Icons.check_circle,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and "New" badge row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isNew)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'New',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
