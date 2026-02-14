import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboard/dashboard_screen.dart';
import '../feed/feed_screen.dart';
import '../games/games_screen.dart';
import '../capsules/capsule_list_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/theme/bondbox_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  String? _teamId;

  @override
  void initState() {
    super.initState();
    _fetchUserTeam();
  }

  Future<void> _fetchUserTeam() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _teamId = doc.data()?['currentTeamId'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const DashboardScreen(),
          _teamId != null 
              ? LeaderboardScreen(teamId: _teamId!) 
              : const Center(child: Text("Join a crew to see the leaderboard!")),
          const GamesScreen(),
          CapsuleListScreen(groupId: _teamId),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_filled, "Home"),
            _buildNavItem(1, Icons.emoji_events_outlined, "Ranks"),
            _buildNavItem(2, Icons.videogame_asset_outlined, "Games"),
            _buildNavItem(3, Icons.photo_library_outlined, "Memories"),
            _buildNavItem(4, Icons.person_outline, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) _fetchUserTeam(); // Refresh team ID when tapping Leaderboard
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? BondBoxColors.primaryPurple : Colors.grey,
            size: 28,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
              decoration: const BoxDecoration(
                color: BondBoxColors.primaryPurple,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
