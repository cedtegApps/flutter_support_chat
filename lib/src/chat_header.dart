import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'model/chat.dart';
import 'model/state.dart';

class FlutterSupportChatHeaderButton extends StatelessWidget {
  FlutterSupportChatHeaderButton({
    Key? key,
    required this.supporterID,
    required this.currentID,
    required this.firestoreInstance,
    required this.closeCaseText,
    required this.id,
    required this.back,
  }) : super(key: key);

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

  /// `closeCaseText` is a optional String.
  /// This text is when a case should be closed
  final String closeCaseText;

  /// `id` is should only used in FlutterSupportChat.
  final String id;

  /// `back` is should only used in FlutterSupportChat.
  final Function back;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                back();
              },
              icon: Icon(
                Icons.arrow_back,
              ),
            ),
            IconButton(
              onPressed: () async {
                var result = await showOkCancelAlertDialog(
                  context: context,
                  title: closeCaseText,
                );
                if (result == OkCancelResult.ok) {
                  final SupportChat c = SupportChat.fromFireStore(
                    await firestoreInstance
                        .collection(
                          'flutter_support_chat',
                        )
                        .doc(id)
                        .get(),
                  );
                  c.state = SupportCaseState.closed;
                  await c.update(
                    firestoreInstance.collection(
                      'flutter_support_chat',
                    ),
                  );
                  back();
                }
              },
              icon: Icon(
                Icons.close,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
