import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final DocumentSnapshot doc;

  const ChatPage({super.key, required this.doc});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Page"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: widget.doc.reference.collection('messages').orderBy('time').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data?.docs.isEmpty ?? true) {
                    return Text("No messages yet!");
                  }
                  return ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        DocumentSnapshot msg = snapshot.data!.docs[index];
                        if (msg['uid'] ==
                            FirebaseAuth.instance.currentUser!.uid) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  msg['message'].toString(),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  msg['message'].toString(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        }
                      });
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: message,
                  decoration: InputDecoration(
                    labelText: "Your Message",
                  ),
                )),
                ElevatedButton(
                  onPressed: () async {
                    await widget.doc.reference.collection('messages').add({
                      'time': DateTime.now(),
                      'uid': FirebaseAuth.instance.currentUser!.uid,
                      'message': message.text,
                    });
                    await widget.doc.reference.update({
                      'recent_text': message.text
                    });
                    message.text = "";
                  },
                  child: Text("Send"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
