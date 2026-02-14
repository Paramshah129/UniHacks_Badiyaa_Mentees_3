import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/bondbox_theme.dart';
import '../../shared/widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      backgroundColor: BondBoxColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final displayName = userData?['nickname'] ?? userData?['fullName'] ?? "Main Character";
          final bio = userData?['bio'] ?? "Writing my story...";
          final avatar = userData?['avatar'];
          final points = userData?['totalPoints'] ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                BondAvatar(
                  radius: 60,
                  imageUrl: avatar,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                const SizedBox(height: 20),
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  bio,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat("$points", "Total XP"),
                      _buildProfileStat("3", "Streak"), // Placeholder streak
                      _buildProfileStat("#1", "Rank"), // Placeholder rank
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildActionItem(Icons.settings_outlined, "Settings"),
                _buildActionItem(Icons.group_add_outlined, "Invite Friends"),
                _buildActionItem(Icons.logout_outlined, "Log Out", isDestructive: true, onTap: () => FirebaseAuth.instance.signOut()),
              ],
            ),
          );
        }
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

  Widget _buildActionItem(IconData icon, String label, {bool isDestructive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
