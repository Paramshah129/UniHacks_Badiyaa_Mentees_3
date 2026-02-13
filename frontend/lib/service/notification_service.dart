import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of notifications for the current user
  Stream<QuerySnapshot> getNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('notifications')
        .where('toUserId', '==', uid)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'status': 'read'});
  }

  // Send a local notification (e.g. for testing or in-app actions not triggered by functions)
  // Real notifications should be triggered by Cloud Functions
  Future<void> sendInAppNotification({
    required String toUserId,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    final currentUser = _auth.currentUser;
    await _firestore.collection('notifications').add({
      'toUserId': toUserId,
      'fromUserId': currentUser?.uid,
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'status': 'unread',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
