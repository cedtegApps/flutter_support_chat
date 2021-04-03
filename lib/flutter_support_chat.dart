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
  final String newCaseText;
  final String createCaseText;
  final String writeMessageText;

  const FlutterSupportChat({
    Key? key,
    required this.supporterEmails,
    required this.currentEmail,
    required this.firestoreInstance,
    required this.newCaseText,
    this.createCaseText = 'Create Support Case',
    this.writeMessageText = 'Write a message...',
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
              widget: widget,
              id: caseId!,
              back: () {
                setState(() {
                  caseId = null;
                });
              },
            )
          : FlutterSupportChatOverview(
              widget: widget,
              selectCase: (id) {
                setState(() {
                  caseId = id;
                });
              },
            ),
    );
  }
}
