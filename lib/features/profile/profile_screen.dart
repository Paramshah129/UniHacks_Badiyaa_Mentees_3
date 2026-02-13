import 'package:flutter/material.dart';
import '../../core/theme/bondbox_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=jack"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Jack Chaos ⚡",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Meme Master • Vibe: ✨",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProfileStat("450", "Total XP"),
                  _buildProfileStat("3", "Streak"),
                  _buildProfileStat("#2", "Global Rank"),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildActionItem(Icons.settings_outlined, "Settings"),
            _buildActionItem(Icons.group_add_outlined, "Invite Friends"),
            _buildActionItem(Icons.logout_outlined, "Log Out", isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: BondBoxColors.primaryPurple)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.red : BondBoxColors.primaryPurple),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDestructive ? Colors.red : BondBoxColors.textPrimary)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
