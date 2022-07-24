import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';
import 'state.dart';

/// `SupportChat` is should only used in FlutterSupportChat.
class SupportChat {
  /// `id` is should only used in FlutterSupportChat.
  String id;

  /// `requester` is should only used in FlutterSupportChat.
  String requester;

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
    required this.requester,
    required this.createTimestamp,
    required this.messages,
    required this.lastEditTimestmap,
    required this.state,
  });

  static SupportChat fromFireStoreQuery(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data();
    return SupportChat(
      id: doc.id,
      requester: data['requester'] ?? data['email'],
      createTimestamp: data['create_timestamp'],
      lastEditTimestmap: data['last_edit_timestamp'],
      messages: data["messages"]
          .map(
            (message) => SupportChatMessage.fromFireStore(
              message,
            ),
          )
          .toList(),
      state: SupportCaseState.values[data["state"] ?? 1],
    );
  }

  static SupportChat fromFireStore(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return SupportChat(
      id: doc.id,
      requester: data['requester'] ?? data['email'],
      createTimestamp: data['create_timestamp'],
      lastEditTimestmap: data['last_edit_timestamp'],
      messages: data["messages"]
          .map(
            (message) => SupportChatMessage.fromFireStore(message),
          )
          .toList(),
      state: SupportCaseState.values[data["state"] ?? 1],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'requester': requester,
      'email': requester,
      'create_timestamp': createTimestamp,
      'last_edit_timestamp': lastEditTimestmap,
      'messages': messages
          .map(
            (message) => message.toFireStore(),
          )
          .toList(),
      'state': state.index
    };
  }

  Future<void> update(CollectionReference<Map<String, dynamic>> support) async {
    return await support.doc(id).update(toFireStore());
  }
}
