import 'package:flutter/material.dart';
import 'package:push_notification/consts.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZimAudioCall extends StatefulWidget {
  final String callId;
  final String userId;
  const ZimAudioCall({super.key, required this.callId, required this.userId});

  @override
  State<ZimAudioCall> createState() => _ZimAudioCallState();
}

class _ZimAudioCallState extends State<ZimAudioCall> {
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: appId,
      appSign: appSign,
      callID: widget.callId,
      userID: widget.userId,
      userName: "User: ${widget.userId}",
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }
}
