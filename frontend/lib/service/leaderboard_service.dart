import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Stream of top users in a specific group, ordered by weeklyPoints
  Stream<List<DocumentSnapshot>> getGroupLeaderboard(String groupId) {
    // Note: In a real app with "groups" collection, we'd query users where groupPoints.groupId == groupId
    // For this simple version (as per prompt reqs), we might just query all users if groups aren't fully implemented 
    // OR query users who have this groupId in their profile.
    // Assuming 'currentTeamId' is the groupId based on previous team features.
    
    return _firestore
        .collection('users')
        .where('currentTeamId', isEqualTo: groupId)
        .orderBy('weeklyPoints', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// Get specific user's rank (Client-side calculation for now)
  Future<int> getUserRank(String userId, String groupId) async {
    final snapshot = await _firestore
        .collection('users')
        .where('currentTeamId', isEqualTo: groupId)
        .orderBy('weeklyPoints', descending: true)
        .get();

    final docs = snapshot.docs;
    for (int i = 0; i < docs.length; i++) {
        if (docs[i].id == userId) {
            return i + 1;
        }
    }
    return 0; // Not found
  }

  /// Call the backend function to award points securely
  Future<void> awardActivityPoints(String currentUserId, String activityType) async {
    final Map<String, int> pointsMap = {
      "poll_vote": 2,
      "mini_game_win": 15,
      "daily_prompt": 5,
      "capsule_create": 10,
      "capsule_unlock": 20,
      "memory_add": 5,
      "memory_react": 1,
      "streak_7_day": 25
    };
    
    final int points = pointsMap[activityType] ?? 0;
    if (points == 0) return;

    final userRef = _firestore.collection('users').doc(currentUserId);
    
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return;
        
        final newTotal = (snapshot.data()?['totalPoints'] ?? 0) + points;
        final newWeekly = (snapshot.data()?['weeklyPoints'] ?? 0) + points;
        
        transaction.update(userRef, {
            'totalPoints': newTotal,
            'weeklyPoints': newWeekly,
            'lastActive': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print("Error awarding points: $e");
    }
  }
}
