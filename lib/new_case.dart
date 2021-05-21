import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'model/chat.dart';
import 'model/message.dart';
import 'overview.dart';

/// `FlutterSupportChatCreateNewCase` is should only used in FlutterSupportChat.
class FlutterSupportChatCreateNewCase extends StatelessWidget {
  const FlutterSupportChatCreateNewCase({
    Key? key,
    required this.widget,
  }) : super(key: key);

  /// `widget` is should only used in FlutterSupportChat.
  final FlutterSupportChatOverview widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () async {
          final DocumentReference d = await support.add(
            SupportChat(
              id: '',
              requesterEmail: widget.widget.currentEmail,
              createTimestamp: Timestamp.now(),
              messages: [
                SupportChatMessage(
                  content: widget.widget.newCaseText,
                  sender: widget.widget.supporterEmails.first,
                  timestamp: Timestamp.now(),
                ),
              ],
              lastEditTimestmap: Timestamp.now(),
            ).toFireStore(),
          );

          widget.selectCase(d.id);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.widget.createCaseText,
            ),
          ],
        ),
      ),
    );
  }
}
