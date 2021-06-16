library flutter_support_chat;

// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/model/state.dart';
import 'flutter_support_chat.dart';
import 'model/chat.dart';
import 'model/message.dart';
import 'new_case.dart';

late CollectionReference<Map<String, dynamic>> support;
late FirebaseFirestore instance;

/// `FlutterSupportChatOverview` is should only used in FlutterSupportChat.
class FlutterSupportChatOverview extends StatefulWidget {
  /// `flutterSupportChat` is should only used in FlutterSupportChat.
  final FlutterSupportChat flutterSupportChat;

  /// `selectCase` is should only used in FlutterSupportChat.
  final Function(String) selectCase;

  const FlutterSupportChatOverview({
    Key? key,
    required this.flutterSupportChat,
    required this.selectCase,
  }) : super(key: key);
  @override
  _FlutterSupportChatOverviewState createState() =>
      _FlutterSupportChatOverviewState();
}

class _FlutterSupportChatOverviewState
    extends State<FlutterSupportChatOverview> {
  @override
  void initState() {
    super.initState();
    instance = widget.flutterSupportChat.firestoreInstance;
    support = instance.collection(
      'flutter_support_chat',
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSupporter = widget.flutterSupportChat.supporterEmails
        .contains(widget.flutterSupportChat.currentEmail);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: isSupporter
          ? support.snapshots()
          : support
              .where(
                'email',
                isEqualTo: widget.flutterSupportChat.currentEmail,
              )
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Text(snapshot.error.toString());
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
                        bool newMessage = false;
                        if (isSupporter &&
                            c.state == SupportCaseState.waitingForSupporter) {
                          newMessage = true;
                        }
                        if (!isSupporter &&
                            c.state == SupportCaseState.waitingForCustomer) {
                          newMessage = true;
                        }
                        return ListTile(
                          leading: newMessage
                              ? Icon(
                                  Icons.message,
                                )
                              : c.state == SupportCaseState.closed
                                  ? Icon(Icons.close)
                                  : null,
                          onTap: () {
                            widget.selectCase(c.id);
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          subtitle: Text(
                            '${(c.messages.last as SupportChatMessage).content.split('\n')[0]} ${(c.messages.last as SupportChatMessage).content.split('\n').length > 1 ? '...' : ''}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                    ),
                    FlutterSupportChatCreateNewCase(
                      flutterSupportChatOverview: widget,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return FlutterSupportChatCreateNewCase(
          flutterSupportChatOverview: widget,
        );
      },
    );
  }
}
