import 'package:flutter/material.dart';

// A simple data model for a notification item.
// This helps separate the data from the UI code.
class NotificationItem {
  final String avatarUrl;
  final String message;
  final String time;

  const NotificationItem({
    required this.avatarUrl,
    required this.message,
    required this.time,
  });
}

// The main screen widget for notifications.
class NtfScreen extends StatelessWidget {
  const NtfScreen({super.key});

  // Dummy data for demonstration purposes.
  // In a real app, this would come from a database or API.
  final List<NotificationItem> todayNotifications = const [
    NotificationItem(
      avatarUrl: 'https://placehold.co/52x52/E8D5C4/313131?text=A',
      message: "~~~가 ‘그래, 오늘 많이 힘들었겠구나’ \n라고 답장이 왔어요",
      time: "2분 전",
    ),
    NotificationItem(
      avatarUrl: 'https://placehold.co/52x52/A1CCD1/313131?text=B',
      message: "화내줄개? 깨에서 새로운 메시지가 왔어요!",
      time: "7분 전",
    ),
  ];

  final List<NotificationItem> pastNotifications = const [
    NotificationItem(
      avatarUrl: 'https://placehold.co/52x52/7469B6/313131?text=C',
      message: "화내줄개? 깨에서 새로운 메시지가 왔어요!",
      time: "1일 전",
    ),
    NotificationItem(
      avatarUrl: 'https://placehold.co/52x52/AD88C6/313131?text=D',
      message: "~~~가 ‘아, 그랬구나. 괜찮아.’ \n라고 답장이 왔어요",
      time: "3일 전",
    ),
    NotificationItem(
      avatarUrl: 'https://placehold.co/52x52/E1AFD1/313131?text=E',
      message: "새로운 아이템이 상점에 입고되었어요!",
      time: "5일 전",
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This allows the body to be drawn behind the app bar.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '알림',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // A transparent background makes the background image visible.
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // 1. Background Image & Darkening Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // [MODIFIED] Use the local day_background image
                image: AssetImage('assets/images/day_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // [MODIFIED] Overlay with 40% opacity
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // 2. Scrollable Notification List
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              children: [
                const SizedBox(height: 60), // Space for the transparent AppBar
                _NotificationSection(
                  title: '오늘',
                  notifications: todayNotifications,
                ),
                const SizedBox(height: 32),
                _NotificationSection(
                  title: '지난 7일간',
                  notifications: pastNotifications,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A reusable widget for a section title (e.g., "오늘").
class _NotificationSection extends StatelessWidget {
  final String title;
  final List<NotificationItem> notifications;

  const _NotificationSection({
    required this.title,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        // Use ListView.separated to easily add spacing between items.
        ListView.separated(
          // These properties are needed when nesting a ListView inside another.
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _NotificationTile(
              message: notification.message,
              time: notification.time,
              avatarUrl: notification.avatarUrl,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
      ],
    );
  }
}

// A reusable widget for a single notification list item.
class _NotificationTile extends StatelessWidget {
  final String message;
  final String time;
  final String avatarUrl;

  const _NotificationTile({
    required this.message,
    required this.time,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x4C898989), // Semi-transparent grey
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: const Color(0xFFD7D7D7),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Align the time text to the top of its space.
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                time,
                style: const TextStyle(
                  color: Color(0xFFAFAFAF),
                  fontSize: 15,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}