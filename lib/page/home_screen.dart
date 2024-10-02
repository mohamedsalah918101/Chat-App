import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Push Notification", style: TextStyle(color: Colors.white),),
      ),
      body: Center(child: Text("Home Page "),),
    );
  }
}
