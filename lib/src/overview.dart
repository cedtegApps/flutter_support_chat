library flutter_support_chat;

// Flutter imports:
import 'package:adaptive_dialog/adaptive_dialog.dart';
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

  /// `closeCaseText` is a optional String.
  /// This text is when a case should be closed
  final String closeCaseText;

  final String deviceInfos;

  const FlutterSupportChatOverview({
    Key? key,
    required this.supporterID,
    required this.currentID,
    required this.firestoreInstance,
    required this.onNewCaseText,
    required this.selectCase,
    required this.createCaseButtonText,
    required this.onNewCaseCreated,
    required this.closeCaseText,
    required this.deviceInfos,
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
                'requester',
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
          List<SupportChat> data = snapshot.data!.docs
              .map((c) => SupportChat.fromFireStoreQuery(c))
              .toList();
          data.sort(
            (a, b) => b.lastEditTimestmap.compareTo(a.lastEditTimestmap),
          );
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FlutterSupportChatCreateNewCase(
                  createCaseButtonText: widget.createCaseButtonText,
                  currentID: widget.currentID,
                  onNewCaseText: widget.onNewCaseText,
                  selectCase: widget.selectCase,
                  supporterID: widget.supporterID,
                  onNewCaseCreated: widget.onNewCaseCreated,
                  deviceInfos: widget.deviceInfos,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 53,
                child: Scrollbar(
                  child: ListView(
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: data.map(
                        (SupportChat chat) {
                          bool newMessage = false;
                          if (isSupporter &&
                              chat.state ==
                                  SupportCaseState.waitingForSupporter) {
                            newMessage = true;
                          }
                          if (!isSupporter &&
                              chat.state ==
                                  SupportCaseState.waitingForCustomer) {
                            newMessage = true;
                          }
                          return ListTile(
                            title: Text(
                              chat.title,
                            ),
                            leading: newMessage
                                ? Icon(
                                    Icons.message,
                                  )
                                : null,
                            onTap: () {
                              widget.selectCase(chat.id);
                            },
                            onLongPress: () async {
                              if (chat.state == SupportCaseState.closed) {
                                return;
                              }
                              var result = await showOkCancelAlertDialog(
                                context: context,
                                title: widget.closeCaseText,
                              );
                              if (result == OkCancelResult.ok) {
                                final SupportChat c = SupportChat.fromFireStore(
                                  await widget.firestoreInstance
                                      .collection(
                                        'flutter_support_chat',
                                      )
                                      .doc(
                                        chat.id,
                                      )
                                      .get(),
                                );
                                c.state = SupportCaseState.closed;
                                await c.update(
                                  widget.firestoreInstance.collection(
                                    'flutter_support_chat',
                                  ),
                                );
                              }
                            },
                            subtitle: Text(
                              '${(chat.messages.last as SupportChatMessage).content.split('\n')[0]} ${(chat.messages.last as SupportChatMessage).content.split('\n').length > 1 ? '...' : ''}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            trailing: Chip(
                              padding: EdgeInsets.all(0),
                              backgroundColor: chat.state ==
                                      SupportCaseState.closed
                                  ? Colors.red
                                  : chat.state ==
                                          SupportCaseState.waitingForCustomer
                                      ? Colors.green
                                      : Colors.orange,
                              label: Text(
                                (chat.messages.last as SupportChatMessage)
                                    .timestamp
                                    .toDate()
                                    .toString()
                                    .substring(0, 16),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ],
          );
        }
        return FlutterSupportChatCreateNewCase(
          currentID: widget.currentID,
          onNewCaseText: widget.onNewCaseText,
          selectCase: widget.selectCase,
          supporterID: widget.supporterID,
          createCaseButtonText: widget.createCaseButtonText,
          onNewCaseCreated: widget.onNewCaseCreated,
          deviceInfos: widget.deviceInfos,
        );
      },
    );
  }
}
