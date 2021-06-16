import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/conversation.dart';
import 'package:flutter_support_chat/model/state.dart';

import 'model/chat.dart';
import 'model/message.dart';

/// `FlutterSupportChatMessageSend` is should only used in FlutterSupportChat.
class FlutterSupportChatMessageSend extends StatefulWidget {
  /// `flutterSupportConversation` is should only used in FlutterSupportChat.
  final FlutterSupportChatConversation flutterSupportConversation;

  /// `support` is should only used in FlutterSupportChat.
  final CollectionReference<Map<String, dynamic>> support;
  const FlutterSupportChatMessageSend({
    required this.flutterSupportConversation,
    required this.support,
  });

  @override
  _FlutterSupportChatMessageSendState createState() =>
      _FlutterSupportChatMessageSendState();
}

class _FlutterSupportChatMessageSendState
    extends State<FlutterSupportChatMessageSend> {
  final TextEditingController _textEditingController = TextEditingController();
  bool sending = false;
  bool enabled = false;
  @override
  void initState() {
    checkIfClosed();
    super.initState();
  }

  bool get isSupporter =>
      widget.flutterSupportConversation.flutterSupportChat.supporterEmails
          .contains(
        widget.flutterSupportConversation.flutterSupportChat.currentEmail,
      );

  Future<void> checkIfClosed() async {
    SupportChat c = SupportChat.fromFireStore(
      await widget.support.doc(widget.flutterSupportConversation.id).get(),
    );
    setState(() {
      enabled = c.state != SupportCaseState.closed;
    });
  }

  send() async {
    sending = true;
    setState(() {});
    final SupportChat c = SupportChat.fromFireStore(
      await widget.support.doc(widget.flutterSupportConversation.id).get(),
    );
    c.messages.add(
      SupportChatMessage(
        content: _textEditingController.text,
        sender:
            widget.flutterSupportConversation.flutterSupportChat.currentEmail,
        timestamp: Timestamp.now(),
      ),
    );
    c.state = isSupporter
        ? SupportCaseState.waitingForCustomer
        : SupportCaseState.waitingForSupporter;
    await c.update(widget.support).then((value) {
      sending = false;
      setState(() {});
    }).onError((error, stackTrace) {
      print(error.toString());
      sending = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          bottom: 10,
          top: 10,
          right: 10,
        ),
        width: double.infinity,
        color: Theme.of(context).bottomAppBarColor,
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textEditingController,
                minLines: 1,
                maxLines: 100,
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: widget.flutterSupportConversation.flutterSupportChat
                      .writeMessageText,
                  border: InputBorder.none,
                ),
                onChanged: (c) {
                  setState(() {});
                },
              ),
            ),
            SizedBox(
              width: 15,
            ),
            if (sending)
              FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator(),
                backgroundColor: Colors.grey,
              )
            else
              FloatingActionButton(
                onPressed: _textEditingController.text.isEmpty ? null : send,
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
                backgroundColor: _textEditingController.text.isEmpty
                    ? Colors.grey
                    : Colors.red,
                elevation: 0,
              ),
          ],
        ),
      ),
    );
  }
}
