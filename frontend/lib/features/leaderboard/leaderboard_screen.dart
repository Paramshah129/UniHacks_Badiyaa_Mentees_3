import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/bondbox_theme.dart';
import '../../service/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final String teamId;
  const LeaderboardScreen({super.key, required this.teamId});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _showEarningRules(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text("How to Earn XP 🚀", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildRuleRow(Icons.person_add_rounded, "Invite a Friend", "+50 XP"),
            _buildRuleRow(Icons.videogame_asset_rounded, "Win Mini Game", "+15 XP"),
            _buildRuleRow(Icons.history_edu_rounded, "Create Time Capsule", "+10 XP"),
            _buildRuleRow(Icons.poll_rounded, "Vote in Poll / Chat", "+2 XP"),
            const SizedBox(height: 20),
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: BondBoxColors.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                    children: [
                        Icon(Icons.info_outline, color: BondBoxColors.primaryPurple, size: 20),
                        SizedBox(width: 12),
                        Expanded(child: Text("Points reset every Sunday at midnight. Keep the streak alive!", style: TextStyle(color: BondBoxColors.primaryPurple, fontWeight: FontWeight.w600, fontSize: 12))),
                    ],
                ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRuleRow(IconData icon, String title, String points) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
              children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: Colors.black54, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const Spacer(),
                  Text(points, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
              ],
          ),
      );
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Vibe Check Leaderboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
            IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: Colors.black87),
                onPressed: () => _showEarningRules(context),
            )
        ],
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                        const Color(0xFFE0C3FC).withOpacity(0.8),
                        Colors.transparent
                    ]
                )
            ),
        ),
      ),
      body: Container(
         decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color(0xFFE0C3FC),
              Color(0xFFF3F4F6),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: _leaderboardService.getGroupLeaderboard(widget.teamId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                  // Catch the Index Error specifically if possible, or generic
                  final error = snapshot.error.toString();
                  if (error.contains("FAILED_PRECONDITION") || error.contains("requires an index")) {
                      return Center(
                          child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                                      const SizedBox(height: 16),
                                      const Text("Database Setup Required", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      const SizedBox(height: 8),
                                      const Text("To see the leaderboard, the developer needs to create a Firestore Index. Check the logs!", textAlign: TextAlign.center),
                                      const SizedBox(height: 24),
                                      SelectableText(error, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                              ),
                          )
                      );
                  }
                  return Center(child: Text("Error loading leaderboard: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data ?? [];
              
              Map<String, dynamic>? currentUserData;
              int userRank = 0;
              
              for (int i = 0; i < docs.length; i++) {
                  if (docs[i].id == currentUserId) {
                      currentUserData = docs[i].data() as Map<String, dynamic>;
                      userRank = i + 1;
                      break;
                  }
              }

              String nextRankMessage = "You're doing great! Keep vibing.";
              if (userRank > 1 && userRank <= docs.length) {
                  final aboveUser = docs[userRank - 2].data() as Map<String, dynamic>;
                  final abovePoints = aboveUser['weeklyPoints'] ?? 0;
                  final myPoints = currentUserData?['weeklyPoints'] ?? 0;
                  final pointsToNext = (abovePoints - myPoints) + 1; 
                  final aboveName = aboveUser['nickname'] ?? 'the person above';
                  nextRankMessage = "You're $pointsToNext XP away from humbling @$aboveName";
              } else if (userRank == 1) {
                  nextRankMessage = "You are the Vibe Main Character! 👑";
              }

              if (currentUserData == null) {
                  return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
                      builder: (context, userSnapshot) {
                          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                           // Use fallback message
                          return _buildScrollableContent(context, docs, userData, 0, "Crack the top 20 to be seen!");
                      }
                  );
              }
              
              return _buildScrollableContent(context, docs, currentUserData, userRank, nextRankMessage);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context, List<DocumentSnapshot> leaderboardDocs, Map<String, dynamic>? userData, int rank, String message) {
      final points = userData?['totalPoints'] ?? 0;
      final weeklyPoints = userData?['weeklyPoints'] ?? 0;

      return CustomScrollView(
        slivers: [
            SliverToBoxAdapter(
                child: Column(
                    children: [
                        const SizedBox(height: 20),
                        _buildCurrentUserCard(userData, rank, points, weeklyPoints, message),
                        const SizedBox(height: 30),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("This Week's Top Vibers", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                            ),
                        ),
                        const SizedBox(height: 16),
                    ],
                ),
            ),
            if (leaderboardDocs.isEmpty)
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Icon(Icons.sentiment_dissatisfied_rounded, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text("No vibers found yet.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                                const SizedBox(height: 50), // Offset a bit
                            ],
                        ),
                    ),
                )
            else
                SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (context, index) {
                                final doc = leaderboardDocs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                return _buildLeaderboardTile(index + 1, data, doc.id == currentUserId);
                            },
                            childCount: leaderboardDocs.length,
                        ),
                    ),
                ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)), 
        ],
      );
  }

  Widget _buildCurrentUserCard(Map<String, dynamic>? data, int rank, int totalPoints, int weeklyPoints, String message) {
      if (data == null) return const SizedBox.shrink();
      
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                  BoxShadow(color: Colors.purple.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
              ]
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                      children: [
                          CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$currentUserId"),
                          ),
                          const SizedBox(width: 16),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  const Text("Main Character", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                                  Text(data['nickname'] ?? "You", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                              ],
                          ),
                          const Spacer(),
                           if (rank > 0)
                            Text("#$rank", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
                      ],
                  ),
                  const SizedBox(height: 24),
                   ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                          value: 0.75, 
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.5),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Your Vibe Level", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text("$totalPoints XP", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                  
                  const SizedBox(height: 16),
                  Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(16), 
                        boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Row(
                          children: [
                              const SizedBox(width: 8),
                              Expanded(child: Text(message, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87))),
                          ],
                      ),
                  )
              ],
          ),
      );
  }

  Widget _buildLeaderboardTile(int rank, Map<String, dynamic> data, bool isMe) {
    Color rankColor;
    switch (rank) {
        case 1: rankColor = const Color(0xFFFFD700); break; // Gold
        case 2: rankColor = const Color(0xFFC0C0C0); break; // Silver
        case 3: rankColor = const Color(0xFFCD7F32); break; // Bronze
        default: rankColor = Colors.grey.shade400;
    }

    Widget? statusIcon;
    if (rank == 1) statusIcon = const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20);
    else if (rank == 3) statusIcon = const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20);

    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: isMe ? BondBoxColors.primaryPurple.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isMe ? Border.all(color: BondBoxColors.primaryPurple, width: 1) : null,
            boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
            ]
        ),
        child: Row(
            children: [
                SizedBox(
                    width: 40,
                    child: Text(
                        "$rank", 
                        style: TextStyle(
                            fontSize: 28, 
                            fontWeight: FontWeight.w900, 
                            color: rankColor,
                            shadows: [
                                Shadow(offset: const Offset(1, 1), color: Colors.black.withOpacity(0.1), blurRadius: 2),
                                Shadow(offset: const Offset(-1, -1), color: Colors.white.withOpacity(0.5), blurRadius: 2)
                            ]
                        ),
                        textAlign: TextAlign.center,
                    ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=${data['nickname']}"),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                             Text(data['nickname'] ?? "Anonymous", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                             if (statusIcon != null) ...[
                                const SizedBox(height: 4),
                                Row(children: [
                                    statusIcon,
                                    const SizedBox(width: 4),
                                    Text(rank == 1 ? "Literal Icon" : "Meme Lord", style: TextStyle(fontSize: 10, color: Colors.grey[600], fontStyle: FontStyle.italic))
                                ])
                             ] else if (rank == 2) ...[
                                 const SizedBox(height: 4),
                                 Text("Chaos Coordinator", style: TextStyle(fontSize: 10, color: Colors.grey[600], fontStyle: FontStyle.italic))
                             ]
                        ],
                    ),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                        Text("${data['weeklyPoints'] ?? 0} XP", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                    ],
                )
            ],
        ),
    );
  }
}
