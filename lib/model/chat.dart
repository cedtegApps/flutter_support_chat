import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_support_chat/model/message.dart';
import 'package:flutter_support_chat/model/state.dart';

/// `SupportChat` is should only used in FlutterSupportChat.
class SupportChat {
  /// `id` is should only used in FlutterSupportChat.
  String id;

  /// `requesterEmail` is should only used in FlutterSupportChat.
  String requesterEmail;

  /// `createTimestamp` is should only used in FlutterSupportChat.
  Timestamp createTimestamp;

  /// `messages` is should only used in FlutterSupportChat.
  List messages;

  /// `lastEditTimestmap` is should only used in FlutterSupportChat.
  Timestamp lastEditTimestmap;

  // 'state' is should only used in FlutterSupportChat
  SupportCaseState state;

  SupportChat({
    required this.id,
    required this.requesterEmail,
    required this.createTimestamp,
    required this.messages,
    required this.lastEditTimestmap,
    required this.state,
  });

  static SupportChat fromFireStoreQuery(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return SupportChat(
      id: doc.id,
      requesterEmail: doc.data()['email'],
      createTimestamp: doc.data()['create_timestamp'],
      lastEditTimestmap: doc.data()['last_edit_timestamp'],
      messages: doc
          .data()["messages"]
          .map(
            (m) => SupportChatMessage.fromFireStore(m),
          )
          .toList(),
      state: SupportCaseState.values[doc.data()["state"] ?? 1],
    );
  }

  static SupportChat fromFireStore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return SupportChat(
      id: doc.id,
      requesterEmail: doc.data()!['email'],
      createTimestamp: doc.data()!['create_timestamp'],
      lastEditTimestmap: doc.data()!['last_edit_timestamp'],
      messages: doc
          .data()!["messages"]
          .map(
            (m) => SupportChatMessage.fromFireStore(m),
          )
          .toList(),
      state: SupportCaseState.values[doc.data()!["state"] ?? 1],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'email': requesterEmail,
      'create_timestamp': createTimestamp,
      'last_edit_timestamp': lastEditTimestmap,
      'messages': messages
          .map(
            (m) => m.toFireStore(),
          )
          .toList(),
      'state': state.index
    };
  }

  Future<void> update(CollectionReference support) async {
    return await support.doc(id).update(toFireStore());
  }
}
