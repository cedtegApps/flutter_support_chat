library flutter_support_chat;

// Flutter imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'model/chat.dart';
import 'model/message.dart';
import 'model/state.dart';
import 'new_case.dart';

late CollectionReference<Map<String, dynamic>> support;
late FirebaseFirestore instance;

/// `FlutterSupportChatOverview` is should only used in FlutterSupportChat.
class FlutterSupportChatOverview extends StatefulWidget {
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

  /// `selectCase` is should only used in FlutterSupportChat.
  final Function(String) selectCase;

  /// `onNewCaseCreated` is a optional Function.
  /// With this for example you can send a push notification to a supporter
  final Function() onNewCaseCreated;

  const FlutterSupportChatOverview(
      {Key? key,
      required this.supporterID,
      required this.currentID,
      required this.firestoreInstance,
      required this.onNewCaseText,
      required this.selectCase,
      required this.createCaseButtonText,
      required this.onNewCaseCreated})
      : super(key: key);
  @override
  _FlutterSupportChatOverviewState createState() =>
      _FlutterSupportChatOverviewState();
}

class _FlutterSupportChatOverviewState
    extends State<FlutterSupportChatOverview> {
  @override
  void initState() {
    super.initState();
    instance = widget.firestoreInstance;
    support = instance.collection(
      'flutter_support_chat',
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSupporter = widget.supporterID.contains(widget.currentID);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: isSupporter
          ? support.snapshots()
          : support
              .where(
                'id',
                isEqualTo: widget.currentID,
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
                        return Card(
                          child: ListTile(
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
                          ),
                        );
                      }).toList(),
                    ),
                    FlutterSupportChatCreateNewCase(
                      createCaseButtonText: widget.createCaseButtonText,
                      currentID: widget.currentID,
                      onNewCaseText: widget.onNewCaseText,
                      selectCase: widget.selectCase,
                      supporterID: widget.supporterID,
                      onNewCaseCreated: widget.onNewCaseCreated,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return FlutterSupportChatCreateNewCase(
          currentID: widget.currentID,
          onNewCaseText: widget.onNewCaseText,
          selectCase: widget.selectCase,
          supporterID: widget.supporterID,
          createCaseButtonText: widget.createCaseButtonText,
          onNewCaseCreated: widget.onNewCaseCreated,
        );
      },
    );
  }
}
