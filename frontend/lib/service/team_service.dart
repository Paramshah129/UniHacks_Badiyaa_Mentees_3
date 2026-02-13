import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new team
  Future<String> createTeam(String teamName) async {
    final uid = _auth.currentUser!.uid;
    final inviteCode = _generateInviteCode();

    final teamDoc = await _firestore.collection('teams').add({
      'name': teamName,
      'inviteCode': inviteCode,
      'createdBy': uid,
      'members': [uid],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update user's current team (Create if not exists)
    await _firestore.collection('users').doc(uid).set({
      'currentTeamId': teamDoc.id,
    }, SetOptions(merge: true));

    return teamDoc.id;
  }

  // Join a team using invite code
  Future<void> joinTeam(String inviteCode) async {
    final uid = _auth.currentUser!.uid;
    
    // Find team by invite code
    final query = await _firestore
        .collection('teams')
        .where('inviteCode', isEqualTo: inviteCode.toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid invite code');
    }

    final teamDoc = query.docs.first;
    final teamId = teamDoc.id;

    // Transactional join
    await _firestore.runTransaction((transaction) async {
      final freshSnapshot = await transaction.get(teamDoc.reference);
      final members = List<String>.from(freshSnapshot.get('members'));

      if (!members.contains(uid)) {
        members.add(uid);
        transaction.update(teamDoc.reference, {'members': members});
      }

      transaction.set(_firestore.collection('users').doc(uid), {
        'currentTeamId': teamId,
      }, SetOptions(merge: true));
    });
  }

  // Get current team stream
  Stream<DocumentSnapshot>? getTeamStream(String teamId) {
    if (teamId.isEmpty) return null;
    return _firestore.collection('teams').doc(teamId).snapshots();
  }

  // Helper: Generate 6-char unique invite code
  String _generateInviteCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
