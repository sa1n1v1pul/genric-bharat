import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../controller/messagecontroller.dart';

class ChatScreen extends StatelessWidget {
  final String name;
  final String avatar;
  final MessageController controller = Get.put(MessageController());
  final ScrollController _scrollController = ScrollController();

  ChatScreen({Key? key, required this.name, required this.avatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Builder(
          builder: (BuildContext context) {
            final ThemeData theme = Theme.of(context);
            final bool isDarkMode = theme.brightness == Brightness.dark;

            return Container(
              padding: const EdgeInsets.only(left: 4),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.white)
                        .withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero, // Remove default padding
              ),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundImage: AssetImage(avatar),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0);
                }
              });
              return ListView.builder(
                reverse: true,
                controller: _scrollController,
                itemCount: controller.chatMessages.length,
                itemBuilder: (context, index) {
                  final message = controller
                      .chatMessages[controller.chatMessages.length - 1 - index];
                  return MessageBubble(
                    message: message['message'],
                    isMe: message['isMe'],
                  );
                },
              );
            }),
          ),
          MessageInput(
            onSendMessage: (message) {
              controller.sendMessage(message);
              // Simulate received message after 1 second
              Future.delayed(const Duration(seconds: 1), () {
                controller.receiveMessage("This is a reply to: $message");
              });
            },
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? CustomTheme.loginGradientStart : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;

  MessageInput({Key? key, required this.onSendMessage}) : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateIconColor);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateIconColor);
    _controller.dispose();
    super.dispose();
  }

  void _updateIconColor() {
    setState(() {
      _isTextEmpty = _controller.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Write message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: const EdgeInsets.all(10.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: _isTextEmpty ? Colors.grey : CustomTheme.loginGradientStart,
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                widget.onSendMessage(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
