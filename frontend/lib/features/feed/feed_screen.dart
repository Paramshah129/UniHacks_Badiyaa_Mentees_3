import 'package:flutter/material.dart';
import '../../core/theme/bondbox_theme.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      appBar: AppBar(
        backgroundColor: BondBoxColors.background,
        elevation: 0,
        title: const Text(
          "Crew Feed",
          style: TextStyle(color: BondBoxColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          _buildRoastModeBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildTextPost(
                  "Jack_Chaos",
                  "Who actually thinks cereal before milk is okay? We need to talk.",
                  "2h ago",
                ),
                _buildMemePost(
                  "SarcasmQueen",
                  "Me trying to explain the lore to my non-existing therapist.",
                  "https://picsum.photos/400/300?meme=1",
                  "4h ago",
                ),
                _buildPollPost(
                  "Dany_Sord",
                  "Most likely to accidentally start a cult?",
                  ["Jack", "Quen", "Me (obviously)"],
                  "6h ago",
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: BondBoxColors.purplePinkGradient,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildRoastModeBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BondBoxColors.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BondBoxColors.primaryPurple.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Roast Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Anonymous crew mode is active.", style: TextStyle(fontSize: 12, color: BondBoxColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (v) {},
            activeColor: BondBoxColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildTextPost(String user, String content, String time) {
    return _buildPostContainer(
      user,
      time,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content, style: const TextStyle(fontSize: 15, height: 1.4, color: BondBoxColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildMemePost(String user, String caption, String url, String time) {
    return _buildPostContainer(
      user,
      time,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildPollPost(String user, String question, List<String> options, String time) {
    return _buildPostContainer(
      user,
      time,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...options.map((opt) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: BondBoxColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(opt, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const Icon(Icons.circle_outlined, size: 18, color: Colors.grey),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPostContainer(String user, String time, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 14, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$user")),
              const SizedBox(width: 10),
              Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          content,
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.pinkAccent, size: 20),
              const SizedBox(width: 6),
              const Text("24", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              const Icon(Icons.mode_comment_rounded, color: Colors.grey, size: 20),
              const SizedBox(width: 6),
              const Text("12", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
