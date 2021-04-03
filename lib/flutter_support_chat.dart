library flutter_support_chat;

// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/conversation.dart';
import 'package:flutter_support_chat/overview.dart';

late CollectionReference support;
late FirebaseFirestore instance;

/// Flutter package to implement a fire store chat between customer and product support
///
///
/// `supporterEmails` is a required list of emails.
/// This Emails are able to view all Cases.
///
/// `currentEmail` is a required email.
/// Cases are visible based on this email, comments are made for this email.
///
/// `firestoreInstance` is required for using firestore
///
/// `newCaseText` is a required String.
/// New Cases will have this message by default.
///
/// `createCaseText` is a optional String.
/// This text is shown on the button to create a new Case
///
/// `writeMessageText` is a optional String.
/// This text is shown on the textfield for new comments
class FlutterSupportChat extends StatefulWidget {
  /// `supporterEmails` is a required list of emails.
  /// This Emails are able to view all Cases.
  final List<String> supporterEmails;

  /// `currentEmail` is a required email.
  /// Cases are visible based on this email, comments are made for this email.
  final String currentEmail;

  /// `firestoreInstance` is required for using firestore
  final FirebaseFirestore firestoreInstance;

  /// `newCaseText` is a required String.
  /// New Cases will have this message by default.
  final String newCaseText;

  /// `createCaseText` is a optional String.
  /// This text is shown on the button to create a new Case
  final String createCaseText;

  /// `writeMessageText` is a optional String.
  /// This text is shown on the textfield for new comments
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
