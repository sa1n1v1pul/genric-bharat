import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import 'chatingarea.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final List<Map<String, dynamic>> messages = [
    {
      'name': 'Kaitlyn',
      'message': 'Awesome Setup',
      'time': '3:02 PM',
      'avatar': 'assets/images/temp1.png',
      'unreadCount': 0,
    },
    {
      'name': 'Chloe',
      'message': "That's Great",
      'time': '2:58 PM',
      'avatar': 'assets/images/temp1.png',
      'unreadCount': 2,
    },
    {
      'name': 'Jorge Henry',
      'message': 'Hey where are you?',
      'time': '2:41 PM',
      'avatar': 'assets/images/temp1.png',
      'unreadCount': 0,
    },
    {
      'name': 'Phoebe',
      'message': 'Busy! Call me in 20 mins',
      'time': '2:27 PM',
      'avatar': 'assets/images/temp1.png',
      'unreadCount': 0,
    },
    {
      'name': 'John Doe',
      'message': "Thank you, It's awesome",
      'time': '2:16 PM',
      'avatar': 'assets/images/temp1.png',
      'unreadCount': 0,
    },
    {
      'name': 'Jacob Pena',
      'message': 'Will update you in evening',
      'time': '3:22 PM',
      'avatar': 'assets/images/temp1.png',
      'unreadCount': 1,
    },
    {
      'name': 'Andrey Jones',
      'message': "That's Great",
      'time': '2:27 PM',
      'avatar': 'assets/images/temp1.png',
      'unreadCount': 0,
    },
    {
      'name': 'John Wick',
      'message': 'How are you?',
      'time': '2:16 PM',
      'avatar': 'assets/images/temp1.png',
      'unreadCount': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: const Text(
          'Chat Room',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 4, // Increase elevation for shadow effect
              shadowColor: Colors.grey.withOpacity(0.5),
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(message['avatar']),
                ),
                title: Text(
                  message['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(message['message']),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message['time'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (message['unreadCount'] > 0)
                      Container(
                        height: 22,
                        width: 22,
                        decoration: BoxDecoration(
                          color: CustomTheme.loginGradientStart,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Center(
                          child: Text(
                            message['unreadCount'].toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Get.to(() => ChatScreen(
                        name: message['name'],
                        avatar: message['avatar'],
                      ));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
