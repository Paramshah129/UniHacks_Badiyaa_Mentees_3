import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get currentUserId => _auth.currentUser!.uid;

  // SIGN UP
  Future<User?> signUp({
    required String fullName,
    required String nickname,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "fullName": fullName,
          "nickname": nickname,
          "email": email,
          "nickname_lowercase": nickname.toLowerCase(),
          "photoUrl": null,
          "createdAt": Timestamp.now(),
          "totalPoints": 0,
          "weeklyPoints": 0,
        });
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _initializeUserPoints(userCredential.user!.uid);
      }

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initializeUserPoints(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final updates = <String, dynamic>{};

        if (data?['weeklyPoints'] == null) updates['weeklyPoints'] = 0;
        if (data?['totalPoints'] == null) updates['totalPoints'] = 200;
        if (data?['nickname_lowercase'] == null && data?['nickname'] != null) {
          updates['nickname_lowercase'] = (data!['nickname'] as String).toLowerCase();
        }

        if (updates.isNotEmpty) {
          await _firestore.collection('users').doc(userId).update(updates);
        }
      }
    } catch (e) {
      print('Error initializing points: $e');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // SEARCH USERS
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    
    // Search by nickname
    final nicknameQuery = await _firestore
        .collection('users')
        .where('nickname_lowercase', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('nickname_lowercase', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
        .limit(10)
        .get();
        
    // Also try email if nickname search is empty or query looks like email
    if (nicknameQuery.docs.isEmpty && query.contains('@')) {
       final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: query)
          .limit(1)
          .get();
       return emailQuery.docs.map((doc) => doc.data()).toList();
    }

    return nicknameQuery.docs
        .where((doc) => doc.id != currentUserId) // Exclude self
        .map((doc) => doc.data())
        .toList();
  }

  // SEND FRIEND REQUEST
  Future<void> sendFriendRequest(String targetUid) async {
    final myUid = currentUserId;
    
    // Check if already friends or if request exists
    final existing = await _firestore
        .collection('friendRequests')
        .where('from', isEqualTo: myUid)
        .where('to', isEqualTo: targetUid)
        .get();
        
    if (existing.docs.isNotEmpty) return;

    await _firestore.collection('friendRequests').add({
      'from': myUid,
      'to': targetUid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // GET PENDING REQUESTS
  Stream<List<Map<String, dynamic>>> getPendingRequests() {
    return _firestore
        .collection('friendRequests')
        .where('to', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
           List<Map<String, dynamic>> results = [];
           for (var doc in snapshot.docs) {
             final fromUid = doc.get('from');
             final userDoc = await _firestore.collection('users').doc(fromUid).get();
             if (userDoc.exists) {
               results.add({
                 'requestId': doc.id,
                 'fromUid': fromUid,
                 ...userDoc.data()!,
               });
             }
           }
           return results;
        });
  }

  // ACCEPT FRIEND REQUEST
  Future<void> acceptFriendRequest(String requestId, String fromUid) async {
    final myUid = currentUserId;

    await _firestore.runTransaction((transaction) async {
      // 1. Update request status
      transaction.update(_firestore.collection('friendRequests').doc(requestId), {
        'status': 'accepted'
      });

      // 2. Create friendship record
      final friendshipId = myUid.hashCode <= fromUid.hashCode 
          ? '${myUid}_$fromUid' 
          : '${fromUid}_$myUid';
          
      transaction.set(_firestore.collection('friendships').doc(friendshipId), {
        'uids': [myUid, fromUid],
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  // GET SUGGESTIONS (Based on shared teams or just recent users for now)
  Future<List<Map<String, dynamic>>> getSuggestions() async {
    // For now, just return 5 most recent users who aren't self and aren't friends
    final users = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
        
    return users.docs
        .where((doc) => doc.id != currentUserId)
        .map((doc) => doc.data())
        .take(5)
        .toList();
  }
}