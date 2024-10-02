import 'package:flutter/material.dart';
import 'package:push_notification/consts.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZimVideoCall extends StatefulWidget {
  final String callId;
  final String userId;
  const ZimVideoCall({super.key, required this.callId, required this.userId});

  @override
  State<ZimVideoCall> createState() => _ZimVideoCallState();
}

class _ZimVideoCallState extends State<ZimVideoCall> {
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
        appID: appId,
        appSign: appSign,
        callID: widget.callId,
        userID: widget.userId,
        userName: "User: ${widget.userId}",
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
