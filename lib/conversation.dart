library flutter_support_chat;

// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/model/chat.dart';
import 'package:flutter_support_chat/model/message.dart';

late CollectionReference support;

/// Flutter plugin for implemening a support chat
class FlutterSupportChatConversation extends StatefulWidget {
  final List<String> supporterEmails;
  final String currentEmail;
  final FirebaseFirestore firestoreInstance;
  final String id;
  final Function back;

  const FlutterSupportChatConversation({
    Key? key,
    required this.supporterEmails,
    required this.currentEmail,
    required this.firestoreInstance,
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
    support = widget.firestoreInstance.collection(
      'flutter_support_chat',
    );
    super.initState();
  }

  bool isSender(SupportChatMessage message) =>
      message.sender == widget.currentEmail;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            padding: EdgeInsets.only(
              left: 10,
              bottom: 10,
              top: 10,
            ),
            width: double.infinity,
            color: Theme.of(context).bottomAppBarColor,
            child: ElevatedButton(
              onPressed: () {
                widget.back();
              },
              child: Icon(
                Icons.arrow_back,
              ),
            ),
          ),
        ),
        StreamBuilder<DocumentSnapshot>(
          stream: support.doc(widget.id).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            final doc = SupportChat.fromFireStore(snapshot.data!);
            return Container(
              margin: EdgeInsets.fromLTRB(0, 70, 0, 70),
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: doc.messages.length,
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
                        alignment: isSender(doc.messages[index])
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                isSender(doc.messages[index]) ? 20 : -20,
                              ),
                              bottomLeft: Radius.circular(20),
                              topRight: Radius.circular(
                                !isSender(doc.messages[index]) ? 20 : -20,
                              ),
                              bottomRight: Radius.circular(20),
                            ),
                            color: isSender(doc.messages[index])
                                ? Colors.red
                                : Colors.blueGrey,
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                doc.messages[index].timestamp
                                    .toDate()
                                    .toLocal()
                                    .toString()
                                    .substring(0, 16),
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                doc.messages[index].content,
                                style: TextStyle(
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
        ChatMessageSend(
          id: widget.id,
          email: widget.currentEmail,
          support: support,
        ),
      ],
    );
  }
}

class ChatMessageSend extends StatefulWidget {
  final String id;
  final CollectionReference support;
  final String email;
  const ChatMessageSend({
    required this.id,
    required this.support,
    required this.email,
  });

  @override
  _ChatMessageSendState createState() => _ChatMessageSendState();
}

class _ChatMessageSendState extends State<ChatMessageSend> {
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
                  hintText: 'Schreibe eine Nachricht...',
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
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
                          await support.doc(widget.id).get(),
                        );
                        c.messages.add(
                          SupportChatMessage(
                            content: _textEditingController.text,
                            sender: widget.email,
                            timestamp: Timestamp.now(),
                          ),
                        );
                        _textEditingController.clear();
                        await c.update(support).then((value) {
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
