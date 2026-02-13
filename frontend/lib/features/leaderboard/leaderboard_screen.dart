import 'package:flutter/material.dart';
import '../../core/theme/bondbox_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      appBar: AppBar(
        backgroundColor: BondBoxColors.background,
        elevation: 0,
        title: const Text(
          "Chaos Ranks",
          style: TextStyle(color: BondBoxColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          _buildPodium(context),
          const SizedBox(height: 40),
          _buildSectionHeader("Full Receipts"),
          const SizedBox(height: 16),
          _buildRankItem(4, "Crypto_King", "1020 XP"),
          _buildRankItem(5, "Jack (You)", "950 XP", isMe: true),
          _buildRankItem(6, "SarcasmQueen", "890 XP"),
          _buildRankItem(7, "DankLord", "820 XP"),
        ],
      ),
    );
  }

  Widget _buildPodium(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumUser(Icons.workspace_premium_outlined, "Dany_S", "1280 XP", 36, color: Colors.blueGrey),
        const SizedBox(width: 16),
        _buildPodiumUser(Icons.workspace_premium, "Quen_C", "1520 XP", 50, isHero: true, color: BondBoxColors.primaryPurple),
        const SizedBox(width: 16),
        _buildPodiumUser(Icons.workspace_premium_outlined, "Zoe_99", "1150 XP", 36, color: Colors.brown[300]!),
      ],
    );
  }

  Widget _buildPodiumUser(IconData icon, String name, String xp, double radius, {bool isHero = false, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: isHero ? 32 : 24),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isHero ? BondBoxColors.purplePinkGradient : null,
            color: isHero ? null : Colors.grey[300],
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$name"),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isHero ? 14 : 12)),
        Text(xp, style: const TextStyle(fontSize: 10, color: BondBoxColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BondBoxColors.textSecondary),
    );
  }

  Widget _buildRankItem(int rank, String name, String xp, {bool isMe = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? BondBoxColors.primaryPurple.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isMe ? Border.all(color: BondBoxColors.primaryPurple.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Text("#$rank", style: const TextStyle(fontWeight: FontWeight.bold, color: BondBoxColors.textSecondary)),
          const SizedBox(width: 16),
          CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$name")),
          const SizedBox(width: 16),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Text(xp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: BondBoxColors.textPrimary)),
        ],
      ),
    );
  }
}
