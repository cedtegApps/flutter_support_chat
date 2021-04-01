library flutter_support_chat;

// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/conversation.dart';
import 'package:flutter_support_chat/overview.dart';

late CollectionReference support;
late FirebaseFirestore instance;

/// Flutter plugin for implemening a support chat
class FlutterSupportChat extends StatefulWidget {
  final List<String> supporterEmails;
  final String currentEmail;
  final FirebaseFirestore firestoreInstance;

  const FlutterSupportChat({
    Key? key,
    required this.supporterEmails,
    required this.currentEmail,
    required this.firestoreInstance,
  }) : super(key: key);
  @override
  _FlutterSupportChatState createState() => _FlutterSupportChatState();
}

class _FlutterSupportChatState extends State<FlutterSupportChat> {
  String? caseId;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: caseId != null
          ? FlutterSupportChatConversation(
              currentEmail: widget.currentEmail,
              supporterEmails: widget.supporterEmails,
              firestoreInstance: widget.firestoreInstance,
              id: caseId!,
              back: () {
                setState(() {
                  caseId = null;
                });
              },
            )
          : FlutterSupportChatOverview(
              currentEmail: widget.currentEmail,
              supporterEmails: widget.supporterEmails,
              firestoreInstance: widget.firestoreInstance,
              selectCase: (id) {
                setState(() {
                  caseId = id;
                });
              },
            ),
    );
  }
}
