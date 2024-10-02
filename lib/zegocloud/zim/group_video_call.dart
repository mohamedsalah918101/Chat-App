import 'package:flutter/material.dart';
import 'package:push_notification/consts.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class GroupVideoCall extends StatelessWidget {
  final String callID;
  final String uid;

  const GroupVideoCall({super.key, required this.callID, required this.uid});

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: appId,
      appSign: appSign,
      callID: callID,
      userID: uid,
      userName: "user$uid",
      config: ZegoUIKitPrebuiltCallConfig.groupVideoCall(),
    );
  }
}
