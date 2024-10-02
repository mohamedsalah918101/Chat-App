import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:push_notification/zegocloud/views/auth/login.dart';
import 'package:push_notification/zegocloud/views/home/search.dart';
import 'package:push_notification/zegocloud/views/home/utils/image_post.dart';
import 'package:push_notification/zegocloud/views/home/utils/text_post.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController postText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SearchPage()));
              },
              icon: Icon(Icons.search))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false);
              },
              title: Text("Sign Out"),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
              ),
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(
                    controller: postText,
                    decoration: InputDecoration(labelText: "Post something"),
                  ),
                  SizedBox(height: 4,),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            var data = {
                              'time': DateTime.now(),
                              'type': 'text',
                              'content': postText.text,
                              'uid': FirebaseAuth.instance.currentUser!.uid,
                            };
                            FirebaseFirestore.instance.collection('posts').add(data);
                            postText.text = "";
                            setState(() {

                            });
                          },
                          child: Text("Post")
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('timeline').get(),
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      if(snapshot.data?.docs.isEmpty ?? true){
                        return Text("No Posts for you");
                      } else {
                        return ListView.builder(
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index){
                              return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance.collection('posts').doc((snapshot.data?.docs[index].data() as Map)['post']).get(),
                                  builder: (context, postSnapshot){
                                    if(postSnapshot.hasData){
                                      switch(postSnapshot.data!['type']) {
                                        case 'text': return TextPost(text: postSnapshot.data!['content']);
                                        case 'image': return ImagePost(
                                          text: postSnapshot.data!['content'],
                                          url: postSnapshot.data!['url'],
                                        );
                                        default: return TextPost(text: postSnapshot.data!['content']);
                                      }
                                    }else{
                                      return CircularProgressIndicator();
                                    }
                                  }
                              );
                            }
                        );
                      }
                    }else{
                      return LinearProgressIndicator();
                    }
                  }
              ),
            )
          ],
        ),
      ),
    );
  }
}
