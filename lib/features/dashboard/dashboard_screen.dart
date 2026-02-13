import 'package:flutter/material.dart';
import '../../core/theme/bondbox_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildTopBar(context),
              const SizedBox(height: 24),
              _buildRedeemSection(context),
              const SizedBox(height: 24),
              _buildJoinCrewSection(context),
              const SizedBox(height: 24),
              _buildHighlightCard(context),
              const SizedBox(height: 32),
              _buildSectionHeader(context, "Games"),
              const SizedBox(height: 16),
              _buildGamesSection(context),
              const SizedBox(height: 32),
              _buildSectionHeader(context, "Time Capsules"),
              const SizedBox(height: 16),
              _buildTimeCapsulesSection(context),
              const SizedBox(height: 32),
              _buildSectionHeader(context, "Memory Vault"),
              const SizedBox(height: 16),
              _buildMemoryVaultSection(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=jack"),
              ),
              const SizedBox(width: 12),
              Text(
                "Welcome Back, Jack!",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: BondBoxColors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BondBoxColors.softYellow.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BondBoxColors.softYellow.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BondBoxColors.softYellow.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "1,250 XP to Redeem",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Tap to view your rewards",
                  style: TextStyle(fontSize: 12, color: BondBoxColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: BondBoxColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (title == "Games")
          const Row(
            children: [
              Text("Rank", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
            ],
          ),
      ],
    );
  }

  Widget _buildHighlightCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BondBoxColors.accentBlue.withOpacity(0.3),
            BondBoxColors.secondaryPink.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            bottom: 0,
            top: 20,
            child: Image.network(
              "https://api.iconify.design/noto:people-holding-hands-medium-light-skin-tone-medium-dark-skin-tone.svg",
              width: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 150),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: BondBoxColors.primaryPurple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.circle, color: BondBoxColors.primaryPurple, size: 8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Hyllight",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BondBoxColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Who's most likely to stare\ngroup pictures?",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: BondBoxColors.textPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BondBoxColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Vote Now", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinCrewSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BondBoxColors.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BondBoxColors.primaryPurple.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Join your crew",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter Crew Code",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: BondBoxColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                child: const Text("Join", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGamesSection(BuildContext context) {
    final games = [
      {"name": "Who's Most\nLikely To", "color": BondBoxColors.accentBlue, "bg": const Color(0xFFD1FAE5), "icon": Icons.psychology_alt_rounded},
      {"name": "Guess Who", "color": BondBoxColors.secondaryPink, "bg": const Color(0xFFFEE2E2), "icon": Icons.person_search_rounded},
      {"name": "Meme Battle", "color": BondBoxColors.accentBlue, "bg": const Color(0xFFE0F2FE), "icon": Icons.image_rounded},
      {"name": "Rapid Fire\nPoll", "color": BondBoxColors.primaryPurple, "bg": const Color(0xFFEDE9FE), "icon": Icons.bolt_rounded},
    ];

    return SizedBox(
      height: 120, // Increased height for icons
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: game['bg'] as Color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(game['icon'] as IconData, size: 24, color: game['color'] as Color),
                const SizedBox(height: 8),
                Text(
                  game['name'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: (game['color'] as Color),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: (game['color'] as Color), 
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeCapsulesSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Time Capsules",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, size: 16, color: Color(0xFF065F46)),
                  SizedBox(width: 4),
                  Text(
                    "Create Capsule",
                    style: TextStyle(
                      color: Color(0xFF065F46),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: BondBoxColors.primaryPurple.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: BondBoxColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.liquor_rounded, size: 60, color: BondBoxColors.accentBlue.withOpacity(0.3)),
                      const Icon(Icons.lock_rounded, size: 24, color: Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Summer Daze '24",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Unlocks in 3 weeks",
                      style: TextStyle(color: BondBoxColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          width: 45,
                          child: Stack(
                            children: [
                              const CircleAvatar(
                                radius: 10,
                                backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=a"),
                              ),
                              Positioned(
                                left: 14,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=b"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "3 friends contributed",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BondBoxColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryVaultSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Image Grid
          Expanded(
            flex: 3,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
              children: List.generate(6, (index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://picsum.photos/200/200?sig=$index",
                  fit: BoxFit.cover,
                ),
              )),
            ),
          ),
          const SizedBox(width: 24),
          // Right Side: Top Memories List
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Top Memories",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildMemoryTile("Pixel_Pioneer_99", Icons.favorite_rounded, Colors.pinkAccent),
                _buildMemoryTile("Pixel_Pioneer_99", Icons.favorite_rounded, Colors.pinkAccent),
                _buildMemoryTile("SarcasmQuen_22", Icons.star_rounded, Colors.orange),
                _buildMemoryTile("SarcasmQueen22", Icons.sentiment_very_satisfied_rounded, Colors.yellow[700]!),
                _buildMemoryTile("Senlrig 15 toes", Icons.star_rounded, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryTile(String name, IconData emojiIcon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$name"),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: BondBoxColors.textPrimary),
            ),
          ),
          Icon(emojiIcon, size: 14, color: iconColor),
        ],
      ),
    );
  }
}
