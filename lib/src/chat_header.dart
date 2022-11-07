import 'package:flutter/material.dart';

class FlutterSupportChatHeaderButton extends StatelessWidget {
  FlutterSupportChatHeaderButton({
    Key? key,
    required this.supporterID,
    required this.currentID,
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

  /// `id` is should only used in FlutterSupportChat.
  final String id;

  /// `back` is should only used in FlutterSupportChat.
  final Function back;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        back();
      },
      icon: Icon(
        Icons.adaptive.arrow_back,
      ),
    );
  }
}
