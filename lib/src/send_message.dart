import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'model/chat.dart';
import 'model/message.dart';
import 'model/state.dart';

/// `FlutterSupportChatMessageSend` is should only used in FlutterSupportChat.
class FlutterSupportChatMessageSend extends StatefulWidget {
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

  /// `id` is should only used in FlutterSupportChat.
  final String id;

  /// `writeMessageText` is a optional String.
  /// This text is shown on the textfield for new comments
  final String writeMessageText;

  /// `onNewMessageCreated` is a optional Function.
  /// With this for example you can send a push notification
  final Function(SupportChat) onNewMessageCreated;

  final String deviceInfos;

  FlutterSupportChatMessageSend({
    required this.supporterID,
    required this.currentID,
    required this.firestoreInstance,
    required this.id,
    required this.writeMessageText,
    required this.onNewMessageCreated,
    required this.deviceInfos,
  });

  @override
  _FlutterSupportChatMessageSendState createState() =>
      _FlutterSupportChatMessageSendState();
}

class _FlutterSupportChatMessageSendState
    extends State<FlutterSupportChatMessageSend> {
  final TextEditingController _textEditingController = TextEditingController();
  bool sending = false;
  bool enabled = false;
  @override
  void initState() {
    checkIfClosed();
    super.initState();
  }

  bool get isSupporter => widget.supporterID.contains(
        widget.currentID,
      );

  Future<void> checkIfClosed() async {
    SupportChat c = SupportChat.fromFireStore(
      await widget.firestoreInstance
          .collection(
            'flutter_support_chat',
          )
          .doc(widget.id)
          .get(),
    );
    setState(() {
      enabled = c.state != SupportCaseState.closed;
    });
  }

  send() async {
    sending = true;
    setState(() {});
    final SupportChat c = SupportChat.fromFireStore(
      await widget.firestoreInstance
          .collection(
            'flutter_support_chat',
          )
          .doc(widget.id)
          .get(),
    );
    c.messages.add(
      SupportChatMessage(
        content: _textEditingController.text.trim(),
        sender: widget.currentID,
        timestamp: Timestamp.now(),
        deviceInfos: widget.deviceInfos,
      ),
    );
    c.state = isSupporter
        ? SupportCaseState.waitingForCustomer
        : SupportCaseState.waitingForSupporter;
    await c
        .update(widget.firestoreInstance.collection(
      'flutter_support_chat',
    ))
        .then((value) {
      sending = false;
      _textEditingController.clear();
      setState(() {});
      widget.onNewMessageCreated(c);
    }).onError((error, stackTrace) {
      print(error.toString());
      sending = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Card(
        child: Container(
          padding: EdgeInsets.only(
            left: 10,
            bottom: 5,
            top: 5,
            right: 10,
          ),
          width: double.infinity,
          color: Theme.of(context).bottomAppBarTheme.color,
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  minLines: 1,
                  maxLines: 100,
                  enabled: enabled,
                  decoration: InputDecoration(
                    hintText: widget.writeMessageText,
                    border: InputBorder.none,
                  ),
                  onChanged: (c) {
                    setState(() {});
                  },
                ),
              ),
              SizedBox(
                width: 15,
              ),
              if (sending)
                FloatingActionButton(
                  onPressed: null,
                  child: CircularProgressIndicator(),
                  backgroundColor: Colors.grey,
                )
              else
                FloatingActionButton(
                  onPressed:
                      _textEditingController.text.trim().isEmpty ? null : send,
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: _textEditingController.text.isEmpty
                      ? Colors.grey
                      : Colors.red,
                  elevation: 0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
