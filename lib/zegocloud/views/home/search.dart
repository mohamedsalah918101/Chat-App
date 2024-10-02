import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search for a user"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter username",
              ),
              onChanged: (val) {
                username = val;
                setState(() {});
              },
            ),
          ),
          if (username != null)
            if (username!.length > 3)
              FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('username', isEqualTo: username)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // if(snapshot.data == null){
                      //
                      // }
                      if (snapshot.data?.docs.isEmpty ?? false) {
                        return Text("No user found!");
                      }
                      return Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                              DocumentSnapshot doc = snapshot.data!.docs[index];
                              return ListTile(
                                leading: IconButton(
                                    onPressed: () async {
                                      QuerySnapshot q = await FirebaseFirestore
                                          .instance
                                          .collection('chats')
                                          .where(
                                        'users',
                                        arrayContains: [
                                          FirebaseAuth.instance.currentUser!.uid,
                                          doc.id,
                                        ],
                                      ).get();
                                      if (q.docs.isEmpty) {
                                        print("No Doc");
                                        var data = {
                                          'users': [
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            doc.id,
                                          ],
                                          'recent_text': "Hi",
                                        };
                                        await FirebaseFirestore.instance
                                            .collection('chats')
                                            .add(data);
                                      } else {
                                        print("Yes Doc");
                                      }
                                    },
                                    icon: Icon(
                                      Icons.chat,
                                      color: Colors.indigo,
                                    )),
                                title: Text(doc['username']),
                                trailing: FutureBuilder<DocumentSnapshot>(
                                    future: doc.reference
                                        .collection('followers')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data?.exists ?? false) {
                                          return ElevatedButton(
                                              onPressed: () async {
                                                await doc.reference
                                                    .collection('followers')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .delete();
                                                setState(() {});
                                              },
                                              child: Text("Un Follow"));
                                        }
                                        return ElevatedButton(
                                            onPressed: () async {
                                              await doc.reference
                                                  .collection('followers')
                                                  .doc(FirebaseAuth.instance
                                                      .currentUser!.uid)
                                                  .set({
                                                'time': DateTime.now(),
                                              });
                                              setState(() {});
                                            },
                                            child: Text("Follow"));
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    }),
                              );
                            }),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  })
        ],
      ),
    );
  }
}
