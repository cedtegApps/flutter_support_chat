import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_support_chat/model/state.dart';

import 'model/chat.dart';
import 'model/message.dart';
import 'overview.dart';

/// `FlutterSupportChatCreateNewCase` is should only used in FlutterSupportChat.
class FlutterSupportChatCreateNewCase extends StatelessWidget {
  const FlutterSupportChatCreateNewCase({
    Key? key,
    required this.flutterSupportChatOverview,
  }) : super(key: key);

  /// `flutterSupportChatOverview` is should only used in FlutterSupportChat.
  final FlutterSupportChatOverview flutterSupportChatOverview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () async {
          final DocumentReference d = await support.add(
            SupportChat(
              id: '',
              requesterEmail:
                  flutterSupportChatOverview.flutterSupportChat.currentEmail,
              createTimestamp: Timestamp.now(),
              messages: [
                SupportChatMessage(
                  content:
                      flutterSupportChatOverview.flutterSupportChat.newCaseText,
                  sender: flutterSupportChatOverview
                      .flutterSupportChat.supporterEmails.first,
                  timestamp: Timestamp.now(),
                ),
              ],
              lastEditTimestmap: Timestamp.now(),
              state: SupportCaseState.waitingForCustomer,
            ).toFireStore(),
          );

          flutterSupportChatOverview.selectCase(d.id);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flutterSupportChatOverview.flutterSupportChat.createCaseText,
            ),
          ],
        ),
      ),
    );
  }
}
