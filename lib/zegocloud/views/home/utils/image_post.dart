import 'package:flutter/material.dart';

class ImagePost extends StatelessWidget {

  final String text;
  final String url;

  const ImagePost({super.key, required this.text, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 1),
        color: Colors.indigo.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
              aspectRatio: 1/1,
              child: Image.network(url, fit: BoxFit.cover,),
          ),
          SizedBox(height: 4,),
          Text(text),
          SizedBox(height: 4,),
        ],
      ),
    );
  }
}
