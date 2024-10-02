import 'package:flutter/material.dart';
import 'package:push_notification/zegocloud/zim/zim_audio_call.dart';
import 'package:push_notification/zegocloud/zim/zim_video_call.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class ZimChatsList extends StatelessWidget {
  const ZimChatsList({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Conversations"),
          actions: [],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ZIMKit().showDefaultNewPeerChatDialog(context);
          },
          child: Icon(Icons.add),
        ),
        body: ZIMKitConversationListView(
          onPressed: (context, conversation, defaultAction) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ZIMKitMessageListPage(
                  conversationID: conversation.id,
                  conversationType: conversation.type,
                  appBarActions: [
                    IconButton(
                      onPressed: () {
                        String id = conversation.id.toString() +
                            ZIMKit().currentUser()!.baseInfo.userID.toString();

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ZimAudioCall(
                              callId: id,
                              userId: conversation.id,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.call),
                    ),
                    IconButton(
                      onPressed: () {
                        String id = conversation.id.toString() +
                            ZIMKit().currentUser()!.baseInfo.userID.toString();

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ZimVideoCall(
                              callId: id,
                              userId: conversation.id,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.videocam),
                    ),
                  ],
                );
              },
            ));
          },
        ),
      ),
    );
  }
}
