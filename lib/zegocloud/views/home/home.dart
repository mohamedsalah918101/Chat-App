import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:push_notification/zegocloud/views/auth/login.dart';
import 'package:push_notification/zegocloud/views/chat_list.dart';
import 'package:push_notification/zegocloud/views/home/home_page.dart';
import 'package:push_notification/zegocloud/views/home/search.dart';
import 'package:push_notification/zegocloud/views/home/utils/image_post.dart';
import 'package:push_notification/zegocloud/views/home/utils/text_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
            BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: "Live"),
          ],
          currentIndex: index,
          onTap: (i) {
            setState(() {
              index = i;
            });
          },
        ),
        body: IndexedStack(
          index: index,
          children: [
            Home(),
            ChatList(),
            Container(),
          ],
        ));
  }
}
