import 'package:flutter/material.dart';
import 'package:push_notification/zegocloud/zim/live_stream.dart';
import 'package:push_notification/zegocloud/zim/zim_chats_list.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class ZimLogin extends StatefulWidget {
  const ZimLogin({super.key});

  @override
  State<ZimLogin> createState() => _ZimLoginState();
}

class _ZimLoginState extends State<ZimLogin> {

  TextEditingController username = TextEditingController();
  TextEditingController userid = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Username",
                border: OutlineInputBorder()
              ),
              controller: username,
            ),
            const SizedBox(height: 12,),
            TextFormField(
              decoration: const InputDecoration(
                  hintText: "User ID",
                  border: OutlineInputBorder()
              ),
              controller: userid,
            ),
            const SizedBox(height: 24,),
            ElevatedButton(
                onPressed: () async {
                  await ZIMKit().connectUser(id: userid.text, name: username.text);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const ZimChatsList(),
                        // builder: (context) => LiveStreamBasePage(),
                    )
                  );
                },
                child: const Text("Connect")
            )
          ],
        ),
      ),
    );
  }
}
