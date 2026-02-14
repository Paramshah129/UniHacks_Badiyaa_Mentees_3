import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'leaderboard_service.dart';

class CapsuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ImagePicker _picker = ImagePicker();

  /// Create a new Time Capsule
  Future<String> createCapsule({
    required String title,
    required String message,
    required DateTime unlockDate,
    List<String> mediaUrls = const [],
    String? groupId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final capsuleData = {
      'createdBy': uid,
      'groupId': groupId,
      'title': title,
      'message': message,
      'mediaUrls': mediaUrls,
      'unlockDate': Timestamp.fromDate(unlockDate),
      'createdAt': FieldValue.serverTimestamp(),
      'isUnlocked': false,
      'contributors': [uid],
    };

    final docRef = await _firestore.collection('capsules').add(capsuleData);

    // Award XP for creating capsule
    await LeaderboardService().awardActivityPoints(uid, 'capsule_create');

    return docRef.id;
  }

  /// Get user's capsules (both private and group)
  Stream<List<DocumentSnapshot>> getUserCapsules(String userId) {
    return _firestore
        .collection('capsules')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          docs.sort((a, b) {
            final aDate = (a.data() as Map<String, dynamic>)['unlockDate'] as Timestamp?;
            final bDate = (b.data() as Map<String, dynamic>)['unlockDate'] as Timestamp?;
            if (aDate == null || bDate == null) return 0;
            return aDate.compareTo(bDate);
          });
          return docs;
        });
  }

  /// Get group capsules
  Stream<List<DocumentSnapshot>> getGroupCapsules(String groupId) {
    return _firestore
        .collection('capsules')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          docs.sort((a, b) {
            final aDate = (a.data() as Map<String, dynamic>)['unlockDate'] as Timestamp?;
            final bDate = (b.data() as Map<String, dynamic>)['unlockDate'] as Timestamp?;
            if (aDate == null || bDate == null) return 0;
            return aDate.compareTo(bDate);
          });
          return docs;
        });
  }

  /// Get all capsules for the user (personal + contributed)
  Stream<List<DocumentSnapshot>> getAllUserCapsules(String userId, String? groupId) {
    // Always query by createdBy to show all user's capsules
    return _firestore
        .collection('capsules')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          docs.sort((a, b) {
            final aDate = (a.data() as Map<String, dynamic>)['unlockDate'] as Timestamp?;
            final bDate = (b.data() as Map<String, dynamic>)['unlockDate'] as Timestamp?;
            if (aDate == null || bDate == null) return 0;
            return aDate.compareTo(bDate);
          });
          return docs;
        });
  }

  /// Unlock a capsule (called when unlock date is reached)
  Future<void> unlockCapsule(String capsuleId, String userId) async {
    await _firestore.collection('capsules').doc(capsuleId).update({
      'isUnlocked': true,
    });

    // Award XP for unlocking capsule
    await LeaderboardService().awardActivityPoints(userId, 'capsule_unlock');
  }

  /// Check if capsule should be unlocked
  bool shouldUnlock(Timestamp unlockDate) {
    return DateTime.now().isAfter(unlockDate.toDate());
  }

  /// Upload media to Cloudinary
  Future<String> uploadCapsuleMedia(File file, String capsuleId) async {
    return await CloudinaryService.uploadImage(file, folder: 'capsules/$capsuleId');
  }

  /// Pick multiple images from gallery
  Future<List<XFile>> pickImages() async {
    final images = await _picker.pickMultiImage();
    return images;
  }

  /// Pick a single image
  Future<XFile?> pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  /// Delete a capsule
  Future<void> deleteCapsule(String capsuleId) async {
    await _firestore.collection('capsules').doc(capsuleId).delete();
    // TODO: Delete associated media from Storage
  }

  /// Add contribution to existing capsule (before unlock)
  Future<void> contributeToCapsule(
    String capsuleId,
    String message,
    List<String> imageUrls,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final capsuleRef = _firestore.collection('capsules').doc(capsuleId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(capsuleRef);
      if (!snapshot.exists) throw Exception("Capsule not found");

      final data = snapshot.data()!;
      if (data['isUnlocked'] == true) {
        throw Exception("Cannot contribute to unlocked capsule");
      }

      List<dynamic> contributors = List.from(data['contributors'] ?? []);
      if (!contributors.contains(uid)) {
        contributors.add(uid);
      }

      List<dynamic> existingUrls = List.from(data['mediaUrls'] ?? []);
      existingUrls.addAll(imageUrls);

      transaction.update(capsuleRef, {
        'contributors': contributors,
        'mediaUrls': existingUrls,
        'message': '${data['message']}\n\n$message',
      });
    });
  }
}
