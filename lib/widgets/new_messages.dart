import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) return;

    FocusScope.of(context).unfocus(); // Close the keyboard
    _messageController.clear();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userdata =
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .get();

      final userDataMap = userdata.data();
      if (userDataMap == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User data not found')));
        return;
      }

      await FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userDataMap['username'],
        'image_url': userDataMap['image_url'],
      });
    } catch (error) {
      print("Error sending message: $error");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        elevation: 10,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: EdgeInsets.only(
            left: 12,
            right: 4,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Send a message...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                onPressed: _submitMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
