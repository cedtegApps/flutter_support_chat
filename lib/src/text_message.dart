import 'package:flutter/material.dart';
import 'package:flutter_support_chat/src/model/message.dart';

class TextMessage extends StatelessWidget {
  final SupportChatMessage message;

  /// `currentID` is a required ID.
  /// Id can be Email or FirebaseUsersId
  /// Cases are visible based on this ID, comments are made for this id.
  final String currentID;
  const TextMessage(
    this.message, {
    Key? key,
    required this.currentID,
  }) : super(key: key);
  bool isSender(SupportChatMessage message) => message.sender == currentID;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: 10,
      ),
      child: Align(
        alignment: isSender(message) ? Alignment.topRight : Alignment.topLeft,
        child: Column(
          children: [
            Text(
              message.timestamp.toDate().toLocal().toString().substring(
                    0,
                    16,
                  ),
              style: TextStyle(
                fontSize: 10,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    isSender(message) ? 20 : -20,
                  ),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(
                    !isSender(message) ? 20 : -20,
                  ),
                  bottomRight: Radius.circular(20),
                ),
                color: isSender(message) ? Colors.red : Colors.blueGrey,
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                message.content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
