import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get global leaderboard stream
  Stream<QuerySnapshot> getGlobalLeaderboard({int limit = 20}) {
    return _firestore
        .collection('users')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Get weekly leaderboard stream
  Stream<QuerySnapshot> getWeeklyLeaderboard({int limit = 20}) {
    return _firestore
        .collection('users')
        .orderBy('weeklyPoints', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Get user's current rank (Client-side approximation or separate collection needed for real rank at scale)
  // For <10k users, fetching top 50 and finding index is okay-ish, but ideally done via Cloud Functions
  // This is a simplified view.
}
