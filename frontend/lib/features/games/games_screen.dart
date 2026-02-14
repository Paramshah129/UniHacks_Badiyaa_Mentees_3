import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/bondbox_theme.dart';
import '../../service/leaderboard_service.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      appBar: AppBar(
        backgroundColor: BondBoxColors.background,
        elevation: 0,
        title: const Text(
          "Gaming Hub",
          style: TextStyle(color: BondBoxColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildActiveBattle(context),
            const SizedBox(height: 32),
            _buildGamesGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBattle(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: BondBoxColors.purplePinkGradient,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("ACTIVE BATTLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Who is most likely to...\nghost after a first date?",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                    LeaderboardService().awardActivityPoints(uid, 'mini_game_win');
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Joined Battle! (+15 XP)"), backgroundColor: BondBoxColors.primaryPurple)
                    );
                }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: BondBoxColors.primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Join Battle", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesGrid(BuildContext context) {
    final games = [
      {"name": "Who's Most Likely To", "color": BondBoxColors.accentBlue, "bg": const Color(0xFFD1FAE5), "icon": Icons.psychology_alt_rounded, "pts": "+30 pts"},
      {"name": "Guess Who", "color": BondBoxColors.secondaryPink, "bg": const Color(0xFFFEE2E2), "icon": Icons.person_search_rounded, "pts": "+50 pts"},
      {"name": "Meme Battle", "color": BondBoxColors.accentBlue, "bg": const Color(0xFFE0F2FE), "icon": Icons.image_rounded, "pts": "+40 pts"},
      {"name": "Rapid Fire Poll", "color": BondBoxColors.primaryPurple, "bg": const Color(0xFFEDE9FE), "icon": Icons.bolt_rounded, "pts": "+25 pts"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85, // Adjusted for slightly better fit
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: game['bg'] as Color,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(game['icon'] as IconData, size: 48, color: game['color'] as Color),
              const SizedBox(height: 16),
              Text(
                game['name'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(color: game['color'] as Color, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                game['pts'] as String,
                style: TextStyle(color: (game['color'] as Color).withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
