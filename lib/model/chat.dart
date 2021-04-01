import 'package:cloud_firestore/cloud_firestore.dart';
import '../flutter_support_chat.dart';
import 'message.dart';

class SupportChat {
  String id;
  String requesterEmail;
  Timestamp createTimestamp;
  List messages;
  Timestamp lastEditTimestmap;
  SupportChat({
    required this.id,
    required this.requesterEmail,
    required this.createTimestamp,
    required this.messages,
    required this.lastEditTimestmap,
  });

  static SupportChat fromFireStoreQuery(QueryDocumentSnapshot doc) {
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
    );
  }

  static SupportChat fromFireStore(DocumentSnapshot doc) {
    return SupportChat(
      id: doc.id,
      requesterEmail: doc.data()!['email'],
      createTimestamp: doc.data()!['create_timestamp'],
      lastEditTimestmap: doc.data()!['last_edit_timestamp'],
      messages: doc.data()!["messages"].map(
            (m) => SupportChatMessage.fromFireStore(m),
          ),
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
          .toList()
    };
  }

  Future<void> update() async {
    final CollectionReference support =
        instance.collection('flutter_support_chat');
    return await support.doc(id).update(toFireStore());
  }
}
