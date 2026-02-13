import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/bondbox_theme.dart';
import '../../service/team_service.dart';
import '../chat/team_chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TeamService _teamService = TeamService();
  final TextEditingController _crewCodeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _crewCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinTeam() async {
    if (_crewCodeController.text.trim().isEmpty) return;
    setState(() => _isJoining = true);
    try {
      await _teamService.joinTeam(_crewCodeController.text.trim());
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Welcome to the crew!")),
      );
      
      // Get the team ID/Name to navigate (Fetching purely for nav)
      // Ideally logic returns this, but for now we fetch user's updated team
      final user = FirebaseAuth.instance.currentUser;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      final teamId = userDoc.data()?['currentTeamId'];
      
      if (teamId != null) {
         final teamDoc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
         final teamName = teamDoc.data()?['name'] ?? "Crew Chat";
         
         Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TeamChatScreen(teamId: teamId, teamName: teamName)),
        );
      }

      _crewCodeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isJoining = false);
    }
  }

  Future<void> _createTeam() async {
    // Show dialog to enter team name
    String teamName = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create a Crew", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          onChanged: (val) => teamName = val,
          decoration: const InputDecoration(hintText: "Enter Crew Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: BondBoxColors.primaryPurple, foregroundColor: Colors.white),
            child: const Text("Create"),
          ),
        ],
      ),
    );

    if (teamName.isNotEmpty) {
      try {
        final teamId = await _teamService.createTeam(teamName);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Crew created successfully!")),
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TeamChatScreen(teamId: teamId, teamName: teamName)),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final teamId = userData?['currentTeamId'] as String?;

        return StreamBuilder<DocumentSnapshot>(
          stream: teamId != null ? _teamService.getTeamStream(teamId) : null,
          builder: (context, teamSnapshot) {
            final teamData = teamSnapshot.data?.data() as Map<String, dynamic>?;

            return Scaffold(
              backgroundColor: BondBoxColors.background,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildTopBar(context, userData, teamData),
                      const SizedBox(height: 24),
                      _buildRedeemSection(context),
                      const SizedBox(height: 24),
                      if (teamId == null)
                        _buildJoinCrewSection(context)
                      else
                        _buildCurrentTeamCard(context, teamData, teamId),
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
        );
      }
    );
  }

  Widget _buildTopBar(BuildContext context, Map<String, dynamic>? userData, Map<String, dynamic>? teamData) {
    final displayName = userData?['nickname'] ?? userData?['fullName'] ?? "Chaos Agent";
    final teamName = teamData?['name'];

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back, $displayName!",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (teamName != null)
                    Text(
                      teamName,
                      style: const TextStyle(fontSize: 12, color: BondBoxColors.primaryPurple, fontWeight: FontWeight.bold),
                    ),
                ],
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

  Widget _buildCurrentTeamCard(BuildContext context, Map<String, dynamic>? teamData, String? teamId) {
    if (teamData == null) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: () {
        if (teamId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeamChatScreen(
                teamId: teamId,
                teamName: teamData['name'] ?? "Crew",
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: BondBoxTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  teamData['name'] ?? "My Crew",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Code: ${teamData['inviteCode']}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                const Text(
                  "Tap to open Crew Chat", 
                   style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
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
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)], // Pastel Blue-Purple
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          // Decorative background elements
          Positioned(right: -20, top: -20, child: Icon(Icons.star_rounded, size: 100, color: Colors.white.withOpacity(0.2))),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const Text(
                      "Your Crew Awaits!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E2C),
                      ),
                    ),
                    Icon(Icons.diversity_3_rounded, color: Colors.indigo.shade400, size: 28),
                  ],
                ),
                const SizedBox(height: 16),
                // Illustration placeholder
                Image.network(
                  "https://api.iconify.design/noto:people-hugging.svg", 
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_,__,___) => const SizedBox(height: 100, child: Icon(Icons.group, size: 50, color: Colors.white)),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Form Your Squad", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _createTeam,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("+ Create New Crew", style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.white.withOpacity(0.5),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Join the Vibe", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Enter Crew Code"),
                                  content: TextField(
                                    controller: _crewCodeController,
                                    decoration: const InputDecoration(hintText: "e.g. 5x82ka", border: OutlineInputBorder()),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _joinTeam();
                                      }, 
                                      child: const Text("Join")
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF60A5FA),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Find a Crew", style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
