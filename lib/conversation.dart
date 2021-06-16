library flutter_support_chat;

// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/flutter_support_chat.dart';
import 'package:flutter_support_chat/model/chat.dart';
import 'package:flutter_support_chat/model/message.dart';
import 'package:flutter_support_chat/send_message.dart';

late CollectionReference<Map<String, dynamic>> support;

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
  @override
  void initState() {
    support = widget.flutterSupportChat.firestoreInstance.collection(
      'flutter_support_chat',
    );
    super.initState();
  }

  bool isSender(SupportChatMessage message) =>
      message.sender == widget.flutterSupportChat.currentEmail;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.back(),
      child: Stack(
        children: <Widget>[
          FlutterSupportChatBackButton(
            widget: widget,
          ),
          StreamBuilder<DocumentSnapshot<SupportChat>>(
            stream: support
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
              return Container(
                margin: EdgeInsets.fromLTRB(0, 70, 0, 70),
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: data.messages.length,
                    shrinkWrap: true,
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
            support: support,
          ),
        ],
      ),
    );
  }
}

class FlutterSupportChatBackButton extends StatelessWidget {
  const FlutterSupportChatBackButton({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final FlutterSupportChatConversation widget;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            widget.back();
          },
          child: Icon(
            Icons.arrow_back,
          ),
        ),
      ),
    );
  }
}
