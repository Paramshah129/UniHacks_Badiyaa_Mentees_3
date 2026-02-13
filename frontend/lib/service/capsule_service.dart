import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CapsuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new Time Capsule
  Future<void> createCapsule({
    required String teamId,
    required String title,
    required DateTime unlockDate,
    required String? message,
    required List<String> imageUrls,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('timeCapsules').add({
      'teamId': teamId,
      'title': title,
      'createdBy': uid,
      'unlockDate': Timestamp.fromDate(unlockDate),
      'isUnlocked': false,
      'contributors': [uid],
      'content': {
        'text': message,
        'imageUrls': imageUrls,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get stream of capsules for a specific team
  Stream<QuerySnapshot> getTeamCapsules(String teamId) {
    return _firestore
        .collection('timeCapsules')
        .where('teamId', '==', teamId)
        .orderBy('unlockDate', descending: false)
        .snapshots();
  }

  // Add contribution to an existing capsule (if not yet unlocked)
  Future<void> contributeToCapsule(String capsuleId, String message, List<String> imageUrls) async {
    final uid = _auth.currentUser!.uid;
    
    final capsuleRef = _firestore.collection('timeCapsules').doc(capsuleId);

    // Transaction to safely add contributor and merge content
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(capsuleRef);
      if (!snapshot.exists) throw Exception("Capsule not found");
      
      final data = snapshot.data()!;
      if (data['isUnlocked'] == true) throw Exception("Cannot contribute to unlocked capsule");

      List<dynamic> contributors = List.from(data['contributors'] ?? []);
      if (!contributors.contains(uid)) {
        contributors.add(uid);
      }
      
      // Simple append logic for MVP - could be a subcollection ideally
      // For now, we just update contributors list to show participation
      transaction.update(capsuleRef, {
        'contributors': contributors,
      });
    });
  }
}
