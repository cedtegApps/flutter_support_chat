import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

/// `SupportChatMessage` is should only used in FlutterSupportChat.
class SupportChatMessage {
  /// `content` is should only used in FlutterSupportChat.
  String content;

  /// `sender` is should only used in FlutterSupportChat.
  String sender;

  /// `timestamp` is should only used in FlutterSupportChat.
  Timestamp timestamp;

  String deviceInfos;

  SupportChatMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
    required this.deviceInfos,
  });

  static SupportChatMessage fromFireStore(Map<String, dynamic> message) {
    return SupportChatMessage(
      content: message['content'],
      sender: message['sender'],
      timestamp: message['timestamp'],
      deviceInfos: message['device_infos'] ?? "",
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'content': content,
      'sender': sender,
      'timestamp': timestamp,
      'device_infos': deviceInfos,
    };
  }
}
