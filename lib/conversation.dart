library flutter_support_chat;

// Flutter imports:
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/flutter_support_chat.dart';
import 'package:flutter_support_chat/model/chat.dart';
import 'package:flutter_support_chat/model/message.dart';
import 'package:flutter_support_chat/model/state.dart';
import 'package:flutter_support_chat/send_message.dart';

/// `FlutterSupportChatConversation` is should only used in FlutterSupportChat.
class FlutterSupportChatConversation extends StatefulWidget {
  /// `flutterSupportChat` is should only used in FlutterSupportChat.
  final FlutterSupportChat flutterSupportChat;

  /// `id` is should only used in FlutterSupportChat.
  final String id;

  /// `back` is should only used in FlutterSupportChat.
  final Function back;

  const FlutterSupportChatConversation({
    Key? key,
    required this.flutterSupportChat,
    required this.id,
    required this.back,
  }) : super(key: key);
  @override
  _FlutterSupportChatConversationState createState() =>
      _FlutterSupportChatConversationState();
}

class _FlutterSupportChatConversationState
    extends State<FlutterSupportChatConversation> {
  final ScrollController _controller = ScrollController();

  bool isSender(SupportChatMessage message) =>
      message.sender == widget.flutterSupportChat.currentEmail;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.back(),
      child: Stack(
        children: <Widget>[
          FlutterSupportChatHeaderButton(
            flutterSupportChatConversation: widget,
          ),
          StreamBuilder<DocumentSnapshot<SupportChat>>(
            stream: widget.flutterSupportChat.firestoreInstance
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
                      return Container(
                        padding: EdgeInsets.only(
                          left: 14,
                          right: 14,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: isSender(data.messages[index])
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  isSender(data.messages[index]) ? 20 : -20,
                                ),
                                bottomLeft: Radius.circular(20),
                                topRight: Radius.circular(
                                  !isSender(data.messages[index]) ? 20 : -20,
                                ),
                                bottomRight: Radius.circular(20),
                              ),
                              color: isSender(data.messages[index])
                                  ? Colors.red
                                  : Colors.blueGrey,
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  data.messages[index].timestamp
                                      .toDate()
                                      .toLocal()
                                      .toString()
                                      .substring(0, 16),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  data.messages[index].content,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          FlutterSupportChatMessageSend(
            flutterSupportConversation: widget,
          ),
        ],
      ),
    );
  }
}

class FlutterSupportChatHeaderButton extends StatelessWidget {
  FlutterSupportChatHeaderButton({
    Key? key,
    required this.flutterSupportChatConversation,
  }) : super(key: key);

  /// `flutterSupportChatConversation` is should only used in FlutterSupportChat.
  final FlutterSupportChatConversation flutterSupportChatConversation;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  flutterSupportChatConversation.back();
                },
                icon: Icon(
                  Icons.arrow_back,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(
                        flutterSupportChatConversation
                            .flutterSupportChat.closeCaseText,
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.cancel_sharp,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final SupportChat c = SupportChat.fromFireStore(
                              await flutterSupportChatConversation
                                  .flutterSupportChat.firestoreInstance
                                  .collection(
                                    'flutter_support_chat',
                                  )
                                  .doc(flutterSupportChatConversation.id)
                                  .get(),
                            );
                            c.state = SupportCaseState.closed;
                            await c.update(
                              flutterSupportChatConversation
                                  .flutterSupportChat.firestoreInstance
                                  .collection(
                                'flutter_support_chat',
                              ),
                            );
                            Navigator.pop(context);
                            flutterSupportChatConversation.back();
                          },
                          icon: Icon(
                            Icons.check,
                          ),
                        )
                      ],
                    ),
                  );
                },
                icon: Icon(
                  Icons.close,
                ),
              ),
            ],
          )),
    );
  }
}
