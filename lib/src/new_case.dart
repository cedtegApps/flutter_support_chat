import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'model/chat.dart';
import 'model/message.dart';
import 'model/state.dart';
import 'overview.dart';

/// `FlutterSupportChatCreateNewCase` is should only used in FlutterSupportChat.
class FlutterSupportChatCreateNewCase extends StatelessWidget {
  /// `supporterID` is a required list of Ids.
  /// Ids can be Email or FirebaseUsersIds
  /// This Ids are able to view all Cases.
  final List<String> supporterID;

  /// `currentID` is a required ID.
  /// Id can be Email or FirebaseUsersId
  /// Cases are visible based on this ID, comments are made for this id.
  final String currentID;

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

  const FlutterSupportChatCreateNewCase({
    Key? key,
    required this.supporterID,
    required this.currentID,
    required this.onNewCaseText,
    required this.createCaseButtonText,
    required this.selectCase,
    required this.onNewCaseCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () async {
          final DocumentReference d = await support.add(
            SupportChat(
              id: '',
              requesterEmail: currentID,
              createTimestamp: Timestamp.now(),
              messages: [
                SupportChatMessage(
                  content: onNewCaseText,
                  sender: supporterID.first,
                  timestamp: Timestamp.now(),
                ),
              ],
              lastEditTimestmap: Timestamp.now(),
              state: SupportCaseState.waitingForCustomer,
            ).toFireStore(),
          );

          selectCase(d.id);
          onNewCaseCreated();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              createCaseButtonText,
            ),
          ],
        ),
      ),
    );
  }
}
