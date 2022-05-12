library flutter_support_chat;

// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'conversation.dart';
import 'overview.dart';

/// Flutter package to implement a fire store chat between customer and product support
///
///
/// `supporterID` is a required list of Ids.
/// Ids can be Email or FirebaseUsersIds
/// This Ids are able to view all Cases.
///
/// `currentID` is a required ID.
/// Id can be Email or FirebaseUsersId
/// Cases are visible based on this ID, comments are made for this id.
///
/// `firestoreInstance` is required for using firestore
///
/// `onNewCaseText` is a required String.
/// New Cases will have this message by default.
/// Message is send by the first supporterID
///
/// `createCaseButtonText` is a optional String.
/// This text is shown on the button to create a new Case
///
/// `writeMessageText` is a optional String.
/// This text is shown on the textfield for new comments
///
/// `closeCaseText` is a optional String.
/// This text is when a case should be closed
class FlutterSupportChat extends StatefulWidget {
  /// `supporterID` is a required list of Ids.
  /// Ids can be Email or FirebaseUsersIds
  /// This Ids are able to view all Cases.
  final List<String> supporterID;

  /// `currentID` is a required ID.
  /// Id can be Email or FirebaseUsersId
  /// Cases are visible based on this ID, comments are made for this id.
  final String currentID;

  /// `firestoreInstance` is required for using firestore
  final FirebaseFirestore firestoreInstance;

  /// `onNewCaseText` is a required String.
  /// New Cases will have this message by default.
  /// Message is send by the first supporterID
  final String onNewCaseText;

  /// `createCaseButtonText` is a optional String.
  /// This text is shown on the button to create a new Case
  final String createCaseButtonText;

  /// `writeMessageText` is a optional String.
  /// This text is shown on the textfield for new comments
  final String writeMessageText;

  /// `closeCaseText` is a optional String.
  /// This text is when a case should be closed
  final String closeCaseText;

  const FlutterSupportChat({
    Key? key,
    required this.supporterID,
    required this.currentID,
    required this.firestoreInstance,
    required this.onNewCaseText,
    this.createCaseButtonText = 'Create Support Case',
    this.writeMessageText = 'Write a message...',
    this.closeCaseText = "Do you really want to close this case?",
  }) : super(key: key);
  @override
  _FlutterSupportChatState createState() => _FlutterSupportChatState();
}

class _FlutterSupportChatState extends State<FlutterSupportChat> {
  String? caseId;
  @override
  Widget build(BuildContext context) {
    instance = widget.firestoreInstance;
    return Container(
      child: caseId != null
          ? FlutterSupportChatConversation(
              id: caseId!,
              back: () {
                setState(() {
                  caseId = null;
                });
              },
              createCaseButtonText: widget.createCaseButtonText,
              currentID: widget.currentID,
              firestoreInstance: widget.firestoreInstance,
              onNewCaseText: widget.onNewCaseText,
              supporterID: widget.supporterID,
              closeCaseText: widget.closeCaseText,
              writeMessageText: widget.writeMessageText,
            )
          : FlutterSupportChatOverview(
              selectCase: (id) {
                setState(() {
                  caseId = id;
                });
              },
              createCaseButtonText: widget.createCaseButtonText,
              currentID: widget.currentID,
              firestoreInstance: widget.firestoreInstance,
              onNewCaseText: widget.onNewCaseText,
              supporterID: widget.supporterID,
            ),
    );
  }
}
