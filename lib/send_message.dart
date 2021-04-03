import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/conversation.dart';

import 'model/chat.dart';
import 'model/message.dart';

class FlutterSupportChatMessageSend extends StatefulWidget {
  final FlutterSupportChatConversation widget;
  final CollectionReference support;
  const FlutterSupportChatMessageSend({
    required this.widget,
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
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          bottom: 10,
          top: 10,
        ),
        width: double.infinity,
        color: Theme.of(context).bottomAppBarColor,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: TextField(
                controller: _textEditingController,
                minLines: 1,
                maxLines: 100,
                decoration: InputDecoration(
                  hintText: widget.widget.widget.writeMessageText,
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
                onPressed: _textEditingController.text.isEmpty
                    ? null
                    : () async {
                        sending = true;
                        setState(() {});
                        final SupportChat c = SupportChat.fromFireStore(
                          await widget.support.doc(widget.widget.id).get(),
                        );
                        c.messages.add(
                          SupportChatMessage(
                            content: _textEditingController.text,
                            sender: widget.widget.widget.currentEmail,
                            timestamp: Timestamp.now(),
                          ),
                        );
                        _textEditingController.clear();
                        await c.update(widget.support).then((value) {
                          sending = false;
                          setState(() {});
                        }).onError((error, stackTrace) {
                          print(error.toString());
                          sending = false;
                          setState(() {});
                        });
                      },
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
