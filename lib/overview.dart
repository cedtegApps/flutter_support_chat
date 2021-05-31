library flutter_support_chat;

// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'flutter_support_chat.dart';
import 'model/chat.dart';
import 'model/message.dart';
import 'new_case.dart';

late CollectionReference<Map<String, dynamic>> support;
late FirebaseFirestore instance;

/// `FlutterSupportChatOverview` is should only used in FlutterSupportChat.
class FlutterSupportChatOverview extends StatefulWidget {
  /// `widget` is should only used in FlutterSupportChat.
  final FlutterSupportChat widget;

  /// `selectCase` is should only used in FlutterSupportChat.
  final Function(String) selectCase;

  const FlutterSupportChatOverview({
    Key? key,
    required this.widget,
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
    instance = widget.widget.firestoreInstance;
    support = instance.collection(
      'flutter_support_chat',
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSupporter =
        widget.widget.supporterEmails.contains(widget.widget.currentEmail);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: isSupporter
          ? support.snapshots()
          : support
              .where(
                'email',
                isEqualTo: widget.widget.currentEmail,
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
                        return GestureDetector(
                          onTap: () {
                            widget.selectCase(c.id);
                          },
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
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        (c.messages.last as SupportChatMessage)
                                            .timestamp
                                            .toDate()
                                            .toString()
                                            .substring(0, 16),
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${(c.messages.last as SupportChatMessage).content.split('\n')[0]} ${(c.messages.last as SupportChatMessage).content.split('\n').length > 1 ? '...' : ''}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    FlutterSupportChatCreateNewCase(
                      widget: widget,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return FlutterSupportChatCreateNewCase(
          widget: widget,
        );
      },
    );
  }
}
