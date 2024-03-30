import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:katalk/auth/auth_service.dart';
import 'package:katalk/chat/chat_services.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverId;
  final String username;
  ChatPage(
      {super.key,
      required this.receiverEmail,
      required this.receiverId,
      required this.username});

  final TextEditingController _messageController = TextEditingController();

  final ChatServices _chatServices = ChatServices();
  final AuthService _auth = AuthService();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatServices.sendMessage(receiverId, _messageController.text);

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          username,
          style: TextStyle(fontFamily: 'DefoFont'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Widget>(
              future: _buildMessageList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data ?? SizedBox();
                }
              },
            ),
          ),
          _buildUserInput()
        ],
      ),
    );
  }

  Future<Widget> _buildMessageList() async {
    String senderID = await _auth.currentUser!.uid;
    return StreamBuilder(
        stream: _chatServices.getMessages(receiverId, senderID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading....");
          }

          return ListView(
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == _auth.currentUser!.uid;

    var alignment =
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    var backgroundColor =
        isCurrentUser ? Color.fromARGB(255, 255, 133, 12) : Colors.grey[200];
    var textColor = isCurrentUser ? Colors.white : Colors.black;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              data['message'],
              style: TextStyle(color: textColor, fontFamily: 'DefoFont'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _messageController,
          obscureText: false,
          decoration: InputDecoration(
            hintText: "Type a message",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9.0),
              borderSide: const BorderSide(
                  color: Color(0xffb0b0b0)), // Changed to const
            ),
            hintStyle: const TextStyle(
                color: Color(0xffff9a53), fontFamily: 'DefoFont'),
          ),
        )),
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(Icons.arrow_upward),
        ),
      ],
    );
  }
}
