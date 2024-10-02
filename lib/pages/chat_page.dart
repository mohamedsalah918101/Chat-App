import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_notification/models/chat.dart';
import 'package:push_notification/models/message.dart';
import 'package:push_notification/models/user_profile.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:push_notification/services/auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:push_notification/services/database_service.dart';
import 'package:push_notification/services/media_service.dart';
import 'package:push_notification/services/storage_service.dart';
import 'package:push_notification/utils.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser, otherUser;
  late AuthService _authService;
  GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.chatUser.uid!,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.pfpUrl);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notifications
      if (message.notification != null) {
        print('Message title: ${message.notification!.title}');
        print('Message body: ${message.notification!.body}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle background/terminated notifications
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: message.data['senderID'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name!),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = _generateChatMessagesList(chat.messages!);
          }
          return DashChat(
            messageOptions: MessageOptions(
              showOtherUsersAvatar: true,
              showTime: true,
            ),
            inputOptions: InputOptions(alwaysShowSend: true, trailing: [
              _mediaMessageButton(),
            ]),
            currentUser: currentUser!,
            onSend: _sendMessage,
            messages: messages,
          );
        });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
    }
    // Fetch the recipient's FCM token
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUser!.id)
        .get();

    String? recipientToken = userDoc['fcmToken'];

    if (recipientToken != null) {
      // Send a notification to the recipient
      await _sendPushNotification(recipientToken, chatMessage.text ?? "");
    }
  }

  Future<void> _sendPushNotification(String token, String messageContent) async {
    final data = {
      "notification": {
        "title": currentUser!.firstName,
        "body": messageContent,
      },
      "priority": "high",
      "to": token,
    };

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=YOUR_SERVER_KEY',
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
    }
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            createdAt: m.sentAt!.toDate(),
            medias: [
              ChatMedia(url: m.content!, fileName: "", type: MediaType.image)
            ]);
      } else {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
        onPressed: () async {
          File? file = await _mediaService.getImageFromGallery();
          if (file != null) {
            String chatID =
                generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
            String? downloadURL = await _storageService.uploadImageToChat(
                file: file, chatID: chatID);
            if (downloadURL != null) {
              ChatMessage chatMessage = ChatMessage(
                  user: currentUser!,
                  createdAt: DateTime.now(),
                  medias: [
                    ChatMedia(
                        url: downloadURL, fileName: "", type: MediaType.image)
                  ]);
              _sendMessage(chatMessage);
            }
          }
        },
        icon: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.primary,
        ));
  }
}
