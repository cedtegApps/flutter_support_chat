library flutter_support_chat;

// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/model/chat.dart';
import 'package:flutter_support_chat/model/message.dart';

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
  @override
  void initState() {
    super.initState();
    instance = widget.firestoreInstance;
    support = instance.collection(
      'flutter-support-chat',
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSupporter = widget.supporterEmails.contains(widget.currentEmail);
    support = instance.collection(
      'flutter_support_chat',
    );
    return StreamBuilder<QuerySnapshot>(
      stream: support.snapshots(),
      //isSupporter
      //? support.snapshots()
      //: support
      //    .where(
      //      'email',
      //      isEqualTo: widget.currentEmail,
      //    )
      //    .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: snapshot.data!.docs
                          .map((c) => SupportChat.fromFireStoreQuery(c))
                          .map((SupportChat c) {
                        return GestureDetector(
                          onTap: () {},
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        c.createTimestamp
                                            .toDate()
                                            .toString()
                                            .substring(0, 10),
                                      ),
                                      Text(
                                        (c.messages.last as SupportChatMessage)
                                            .timestamp
                                            .toDate()
                                            .toString()
                                            .substring(0, 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    CreateNewCase(
                      widget: widget,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return CreateNewCase(
          widget: widget,
        );
      },
    );
  }
}

class CreateNewCase extends StatelessWidget {
  const CreateNewCase({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final FlutterSupportChat widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () async {
          final DocumentReference d = await support.add(
            SupportChat(
              id: '',
              requesterEmail: widget.currentEmail,
              createTimestamp: Timestamp.now(),
              messages: [
                SupportChatMessage(
                  content: 'Test New Case',
                  sender: widget.supporterEmails.first,
                  timestamp: Timestamp.now(),
                ),
              ],
              lastEditTimestmap: Timestamp.now(),
            ).toFireStore(),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Create new Support Case'),
          ],
        ),
      ),
    );
  }
}
