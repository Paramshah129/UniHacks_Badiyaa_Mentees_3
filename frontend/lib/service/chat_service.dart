import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1-on-1 Chat Logic
  String getChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join("_");
  }

  // Maintains compatibility with user's ChatScreen
  Future<void> sendMessage(String otherUserId, String message) async {
    final currentUser = _auth.currentUser!.uid;
    final chatId = getChatId(currentUser, otherUserId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUser,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Maintains compatibility with user's ChatScreen
  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final currentUser = _auth.currentUser!.uid;
    final chatId = getChatId(currentUser, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // --- Group (Team) Chat Logic ---

  Future<void> sendTeamMessage(String teamId, String message, {bool isAnonymous = false}) async {
    final currentUser = _auth.currentUser!.uid;

    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('messages')
        .add({
      'senderId': currentUser,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isAnonymous': isAnonymous,
      'type': 'text',
      'seenBy': [currentUser],
      'reactions': {},
    });
  }

  Stream<QuerySnapshot> getTeamMessages(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // Typing Status
  Future<void> updateTypingStatus(String teamId, bool isTyping) async {
    final currentUser = _auth.currentUser!.uid;
    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('typingStatus')
        .doc(currentUser)
        .set({
      'isTyping': isTyping,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTypingStatuses(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .collection('typingStatus')
        .where('isTyping', isEqualTo: true)
        .snapshots();
  }
}