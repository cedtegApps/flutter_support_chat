import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class SupportChatMessage {
  String content;
  String sender;
  Timestamp timestamp;
  SupportChatMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
  });

  static SupportChatMessage fromFireStore(Map<String, dynamic> message) {
    return SupportChatMessage(
      content: message['content'],
      sender: message['sender'],
      timestamp: message['timestamp'],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'content': content,
      'sender': sender,
      'timestamp': timestamp,
    };
  }
}
