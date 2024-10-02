import 'package:flutter/material.dart';
import 'package:push_notification/consts.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LiveStreamBasePage extends StatefulWidget {
  const LiveStreamBasePage({super.key});

  @override
  State<LiveStreamBasePage> createState() => _LiveStreamBasePageState();
}

class _LiveStreamBasePageState extends State<LiveStreamBasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ZegoLiveStream(
                    userID: '123456',
                    userName: "Start",
                    liveID: "123123",
                  ),
                ),
              );
            },
            child: Text("Start Live Stream"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ZegoLiveStream(
                    userID: '1942004',
                    userName: "Start",
                    liveID: "123123",
                  ),
                ),
              );
            },
            child: Text("Join Live Stream"),
          ),
        ],
      ),
    );
  }
}

class ZegoLiveStream extends StatefulWidget {
  final String userID;
  final String userName;
  final String liveID;

  const ZegoLiveStream(
      {super.key,
      required this.userID,
      required this.userName,
      required this.liveID});

  @override
  State<ZegoLiveStream> createState() => _ZegoLiveStreamState();
}

class _ZegoLiveStreamState extends State<ZegoLiveStream> {
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltLiveStreaming(
      appID: appId,
      appSign: appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      config: widget.userID == '123456'
          ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
          : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
    );
  }
}
