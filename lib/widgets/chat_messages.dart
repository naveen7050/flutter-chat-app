import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return Center(child: Text('No  message found'));
        }
        if (chatSnapshot.hasError) {
          return Center(child: Text('Something went wrong....'));
        }
        final loadedMessage = chatSnapshot.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.only(right: 10, left: 10, bottom: 40),
          reverse: true,
          itemCount: loadedMessage.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessage[index].data();
            final nextChatMessage =
                index + 1 < loadedMessage.length
                    ? loadedMessage[index + 1].data()
                    : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessagesUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame = nextMessagesUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['image_url'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
