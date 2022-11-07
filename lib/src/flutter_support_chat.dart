library flutter_support_chat;

// Flutter imports:
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'conversation.dart';
import 'overview.dart';

/// Flutter package to implement a fire store chat between customer and product support
///
///
/// `supporterID` is a required list of Ids.
/// Ids can be Email or FirebaseUsersIds
/// This Ids are able to view all Cases.
///
/// `currentID` is a required ID.
/// Id can be Email or FirebaseUsersId
/// Cases are visible based on this ID, comments are made for this id.
///
/// `firestoreInstance` is required for using firestore
///
/// `onNewCaseText` is a required String.
/// New Cases will have this message by default.
/// Message is send by the first supporterID
///
/// `createCaseButtonText` is a optional String.
/// This text is shown on the button to create a new Case
///
/// `writeMessageText` is a optional String.
/// This text is shown on the textfield for new comments
///
/// `closeCaseText` is a optional String.
/// This text is when a case should be closed
class FlutterSupportChat extends StatefulWidget {
  /// `supporterID` is a required list of Ids.
  /// Ids can be Email or FirebaseUsersIds
  /// This Ids are able to view all Cases.
  final List<String> supporterIDs;

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

  /// `writeMessageText` is a optional String.
  /// This text is shown on the textfield for new comments
  final String writeMessageText;

  /// `closeCaseText` is a optional String.
  /// This text is when a case should be closed
  final String closeCaseText;

  /// `onNewCaseCreated` is a optional Function.
  /// With this for example you can send a push notification to a supporter
  final Function()? onNewCaseCreated;

  /// `onNewMessageCreated` is a optional Function.
  /// With this for example you can send a push notification
  final Function()? onNewMessageCreated;

  /// `collectDeviceData`
  /// whith this bool parameter you can collect data about the device
  final bool collectDeviceData;

  const FlutterSupportChat({
    Key? key,
    required this.supporterIDs,
    required this.currentID,
    required this.firestoreInstance,
    required this.onNewCaseText,
    this.createCaseButtonText = 'Create Support Case',
    this.writeMessageText = 'Write a message...',
    this.closeCaseText = "Do you really want to close this case?",
    this.onNewCaseCreated,
    this.onNewMessageCreated,
    this.collectDeviceData = true,
  }) : super(key: key);
  @override
  _FlutterSupportChatState createState() => _FlutterSupportChatState();
}

class _FlutterSupportChatState extends State<FlutterSupportChat> {
  String deviceInfos = "platform unknown";
  @override
  void initState() {
    if (widget.collectDeviceData) {
      if (kIsWeb) {
        DeviceInfoPlugin().webBrowserInfo.then((value) {
          deviceInfos =
              "${value.vendor} ${value.language} ${value.deviceMemory}Gb ${value.userAgent}";
          setState(() {});
        });
      } else if (Platform.isAndroid) {
        DeviceInfoPlugin().androidInfo.then(
          (value) {
            deviceInfos =
                "${value.brand}, ${value.model}, ${value.version.sdkInt}, ${value.version.securityPatch} ${value.version.release}";
            setState(() {});
          },
        );
      } else if (Platform.isIOS) {
        DeviceInfoPlugin().iosInfo.then(
          (value) {
            deviceInfos =
                "iOS ${value.utsname}, ${value.model}, ${value.systemVersion}";
            setState(() {});
          },
        );
      } else if (Platform.isLinux) {
        DeviceInfoPlugin().linuxInfo.then(
          (value) {
            deviceInfos = "${value.prettyName}";
            setState(() {});
          },
        );
      } else if (Platform.isMacOS) {
        DeviceInfoPlugin().macOsInfo.then(
          (value) {
            deviceInfos =
                "macOS ${value.osRelease} ${value.model} ${value.arch} ";
            setState(() {});
          },
        );
      } else if (Platform.isWindows) {
        DeviceInfoPlugin().windowsInfo.then(
          (value) {
            deviceInfos = "${value.productName} ${value.displayVersion}";
            setState(() {});
          },
        );
      }
    }
    super.initState();
  }

  String? caseId;
  @override
  Widget build(BuildContext context) {
    instance = widget.firestoreInstance;
    return Container(
      child: caseId != null
          ? FlutterSupportChatConversation(
              id: caseId!,
              back: () {
                setState(() {
                  caseId = null;
                });
              },
              createCaseButtonText: widget.createCaseButtonText,
              currentID: widget.currentID,
              firestoreInstance: widget.firestoreInstance,
              onNewCaseText: widget.onNewCaseText,
              supporterID: widget.supporterIDs,
              writeMessageText: widget.writeMessageText,
              onNewMessageCreated: widget.onNewMessageCreated ?? () {},
              deviceInfos: deviceInfos,
            )
          : FlutterSupportChatOverview(
              selectCase: (id) {
                setState(() {
                  caseId = id;
                });
              },
              createCaseButtonText: widget.createCaseButtonText,
              currentID: widget.currentID,
              firestoreInstance: widget.firestoreInstance,
              onNewCaseText: widget.onNewCaseText,
              supporterID: widget.supporterIDs,
              onNewCaseCreated: widget.onNewCaseCreated ?? () {},
              closeCaseText: widget.closeCaseText,
              deviceInfos: deviceInfos,
            ),
    );
  }
}
