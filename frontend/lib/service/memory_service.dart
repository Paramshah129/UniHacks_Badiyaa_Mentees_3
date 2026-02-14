import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'leaderboard_service.dart';

class MemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ImagePicker _picker = ImagePicker();

  /// Create a new Memory Collection
  Future<String> createMemoryCollection({
    required String groupId,
    required String name,
    required String category,
    required String mood,
    required bool isPrivate,
    DateTime? date,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final collectionData = {
      'groupId': groupId,
      'name': name,
      'category': category,
      'mood': mood,
      'isPrivate': isPrivate,
      'createdBy': uid,
      'createdAt': date != null ? Timestamp.fromDate(date) : FieldValue.serverTimestamp(),
      'contributors': [uid],
    };

    final docRef = await _firestore.collection('memory_collections').add(collectionData);
    return docRef.id;
  }

  /// Get memory collections for the current user (created by them or shared with them)
  Stream<List<DocumentSnapshot>> getMemoryCollections(String groupId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    
    // Query collections where user is a contributor (includes their own)
    return _firestore
        .collection('memory_collections')
        .where('contributors', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          docs.sort((a, b) {
            final aDate = (a.data())['createdAt'] as Timestamp?;
            final bDate = (b.data())['createdAt'] as Timestamp?;
            if (aDate == null || bDate == null) return 0;
            return bDate.compareTo(aDate);
          });
          return docs;
        });
  }

  /// Add a memory to a collection
  Future<String> addMemory({
    required String collectionId,
    required String text,
    String? mediaUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final memoryData = {
      'collectionId': collectionId,
      'userId': uid,
      'text': text,
      'mediaUrl': mediaUrl,
      'reactions': {},
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore.collection('memories').add(memoryData);

    // Award XP for adding memory
    await LeaderboardService().awardActivityPoints(uid, 'memory_add');

    // 🌟 UNIQUE UPDATE: If this memory has an image, update the parent collection's coverUrl!
    // This allows the Calendar to show a preview without querying subcollections.
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
       await _firestore.collection('memory_collections').doc(collectionId).update({
         'coverUrl': mediaUrl, 
       });
    }

    return docRef.id;
  }

  /// Get memories for a collection (realtime)
  Stream<List<DocumentSnapshot>> getMemories(String collectionId) {
    return _firestore
        .collection('memories')
        .where('collectionId', isEqualTo: collectionId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          docs.sort((a, b) {
            final aDate = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bDate = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (aDate == null || bDate == null) return 0;
            return aDate.compareTo(bDate);
          });
          return docs;
        });
  }

  /// Get "On This Day" throwbacks from previous years
  Stream<List<DocumentSnapshot>> getThrowbackMemories() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    final now = DateTime.now();
    
    // Note: Firestore doesn't support month/day filtering directly without stored fields or local filtering.
    // For this demo, we'll fetch collections where user is a contributor and filter locally.
    // In a production app, you'd store 'month' and 'day' as separate fields for efficient querying.
    return _firestore
        .collection('memory_collections')
        .where('contributors', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final data = doc.data();
            final createdAt = data['createdAt'] as Timestamp?;
            if (createdAt == null) return false;
            
            final date = createdAt.toDate();
            // Check if same day/month but different year
            return date.month == now.month && 
                   date.day == now.day && 
                   date.year < now.year;
          }).toList();
        });
  }

  /// Add or update a reaction on a memory
  Future<void> addReaction({
    required String memoryId,
    required String emoji,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final memoryRef = _firestore.collection('memories').doc(memoryId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(memoryRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      Map<String, dynamic> reactions = Map.from(data['reactions'] ?? {});

      // Toggle reaction: if same emoji, remove; otherwise update
      if (reactions[uid] == emoji) {
        reactions.remove(uid);
      } else {
        reactions[uid] = emoji;
        // Award XP only when adding a new reaction
        if (data['reactions']?[uid] == null) {
          await LeaderboardService().awardActivityPoints(uid, 'memory_react');
        }
      }

      transaction.update(memoryRef, {'reactions': reactions});
    });
  }

  /// Upload media to Cloudinary
  Future<String> uploadMemoryMedia(File file, String memoryId) async {
    return await CloudinaryService.uploadImage(file, folder: 'memories/$memoryId');
  }

  /// Pick an image from gallery
  Future<XFile?> pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  /// Delete a memory
  Future<void> deleteMemory(String memoryId) async {
    await _firestore.collection('memories').doc(memoryId).delete();
    // TODO: Delete associated media from Storage
  }
}
