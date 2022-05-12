library flutter_support_chat;

// Flutter imports:
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/src/text_message.dart';
import 'chat_header.dart';
import 'model/chat.dart';
import 'send_message.dart';

/// `FlutterSupportChatConversation` is should only used in FlutterSupportChat.
class FlutterSupportChatConversation extends StatefulWidget {
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

  /// `id` is should only used in FlutterSupportChat.
  final String id;

  /// `back` is should only used in FlutterSupportChat.
  final Function back;

  /// `onNewMessageCreated` is a optional Function.
  /// With this for example you can send a push notification
  final Function() onNewMessageCreated;

  const FlutterSupportChatConversation({
    Key? key,
    required this.id,
    required this.back,
    required this.supporterID,
    required this.currentID,
    required this.firestoreInstance,
    required this.onNewCaseText,
    required this.createCaseButtonText,
    required this.writeMessageText,
    required this.closeCaseText,
    required this.onNewMessageCreated,
  }) : super(key: key);
  @override
  _FlutterSupportChatConversationState createState() =>
      _FlutterSupportChatConversationState();
}

class _FlutterSupportChatConversationState
    extends State<FlutterSupportChatConversation> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.back(),
      child: Stack(
        children: <Widget>[
          FlutterSupportChatHeaderButton(
            back: widget.back,
            closeCaseText: widget.closeCaseText,
            currentID: widget.currentID,
            firestoreInstance: widget.firestoreInstance,
            id: widget.id,
            supporterID: widget.supporterID,
          ),
          StreamBuilder<DocumentSnapshot<SupportChat>>(
            stream: widget.firestoreInstance
                .collection(
                  'flutter_support_chat',
                )
                .doc(widget.id)
                .withConverter<SupportChat>(
                  fromFirestore: (doc, _) => SupportChat.fromFireStore(doc),
                  toFirestore: (supportChat, _) => supportChat.toFireStore(),
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              SupportChat data = snapshot.data!.data()!;
              Timer(
                Duration(milliseconds: 100),
                () => _controller.jumpTo(_controller.position.maxScrollExtent),
              );
              return Container(
                margin: EdgeInsets.fromLTRB(0, 70, 0, 70),
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: data.messages.length,
                    shrinkWrap: true,
                    controller: _controller,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    itemBuilder: (context, index) {
                      return TextMessage(
                        data.messages[index],
                        currentID: widget.currentID,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          FlutterSupportChatMessageSend(
            currentID: widget.currentID,
            firestoreInstance: widget.firestoreInstance,
            id: widget.id,
            supporterID: widget.supporterID,
            writeMessageText: widget.writeMessageText,
            onNewMessageCreated: widget.onNewMessageCreated,
          ),
        ],
      ),
    );
  }
}
