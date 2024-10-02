import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:push_notification/models/chat.dart';
import 'package:push_notification/models/message.dart';
import 'package:push_notification/models/user_profile.dart';
import 'package:push_notification/services/auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:push_notification/utils.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;
  late AuthService _authService;
  GetIt _getIt = GetIt.instance;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionReference();
  }

  void _setupCollectionReference() {
    _usersCollection = _firebaseFirestore
        .collection('users')
        .withConverter<UserProfile>(
        fromFirestore: (snapshots, _) =>
            UserProfile.fromJson(snapshots.data()!),
        toFirestore: (userProfile, _) => userProfile.toJson());
    _chatsCollection =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
            fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
            toFirestore: (chat, _) => chat.toJson());
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExist(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection?.doc(chatID).get();
    if(result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);
    final chat = Chat(id: chatID, participants: [uid1, uid2], messages: []);
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);
    await docRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()]),
    });
  }

  Stream getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection!.doc(chatID).snapshots() as Stream<DocumentSnapshot<Chat>>;
  }

}
