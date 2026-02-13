import 'package:flutter/material.dart';
import '../../core/theme/bondbox_theme.dart';

class CapsuleScreen extends StatelessWidget {
  const CapsuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      appBar: AppBar(
        backgroundColor: BondBoxColors.background,
        elevation: 0,
        title: const Text(
          "Time Capsules",
          style: TextStyle(color: BondBoxColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeroCapsule(),
          const SizedBox(height: 32),
          const Text("ALL CAPSULES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 16),
          _buildCapsuleTile("Locked", "Winter Formal '24", "Unlocks in 3 months", Icons.lock_outline_rounded),
          _buildCapsuleTile("Unlocked", "Chaos Crew Founding", "Shared 1 year ago", Icons.celebration_rounded, isUnlocked: true),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: BondBoxColors.primaryPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Bury New Capsule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeroCapsule() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("NEXT UNLOCK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 12),
                const Text(
                  "Graduation Trip 2025",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text("Unlocks in 14 days", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleTile(String status, String title, String detail, IconData icon, {bool isUnlocked = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? BondBoxColors.accentBlue.withOpacity(0.1) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isUnlocked ? BondBoxColors.accentBlue : Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isUnlocked ? BondBoxColors.accentBlue : Colors.grey)),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(detail, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
