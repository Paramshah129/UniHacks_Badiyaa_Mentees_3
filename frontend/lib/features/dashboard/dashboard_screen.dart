import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:friendsconnect/core/theme/bondbox_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../service/team_service.dart';
import '../../service/memory_service.dart';
import '../chat/team_chat_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../capsules/capsule_list_screen.dart';
import '../memories/memory_collection_screen.dart';
import '../memories/memory_detail_screen.dart';
import '../memories/widgets/mini_calendar.dart';
import '../rewards/rewards_screen.dart';
import 'daily_poll_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TeamService _teamService = TeamService();
  final MemoryService _memoryService = MemoryService();
  final TextEditingController _crewCodeController = TextEditingController();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    // Check for throwbacks after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowThrowbackPopup();
    });
  }

  Future<void> _checkAndShowThrowbackPopup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final teamId = userDoc.data()?['currentTeamId'] as String?;

    // We'll use the service to get throwbacks once
    final throwbacks = await _memoryService.getThrowbackMemories().first;
    if (throwbacks.isNotEmpty && mounted) {
      final data = throwbacks.first.data() as Map<String, dynamic>;
      _showThrowbackDialog(data, teamId);
    }
  }

  void _showThrowbackDialog(Map<String, dynamic> data, String? teamId) {
    final createdAt = (data['createdAt'] as Timestamp).toDate();
    final yearDiff = DateTime.now().year - createdAt.year;
    final dateString = "${createdAt.day}/${createdAt.month}/${createdAt.year}";

    showDialog(
      context: context,
      builder: (context) => FadeInUp(
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Polaroid Frame Style
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            data['coverUrl'] ?? "https://picsum.photos/400/300",
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          // Date Stamp in corner
                          Positioned(
                            bottom: 15,
                            right: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                dateString,
                                style: const TextStyle(
                                  color: Color(0xFFFFA500),
                                  fontFamily: 'Courier', // Retro feel
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          data['name'] ?? "A Special Memory",
                          style: const TextStyle(
                            fontFamily: 'Caveat', // Handwritten feel if available
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "✨ It's been $yearDiff ${yearDiff > 1 ? "years" : "year"}! ✨",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: BondBoxColors.primaryPurple),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Reliving this moment today...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (teamId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemoryCollectionScreen(groupId: teamId),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Join a crew to view memories!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BondBoxColors.primaryPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("View in Vault", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please Login")));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${userSnapshot.error}")));
        }
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final teamId = userData?['currentTeamId'] as String?;

        return StreamBuilder<DocumentSnapshot>(
          stream: teamId != null ? _teamService.getTeamStream(teamId) : null,
          builder: (context, teamSnapshot) {
            if (teamId != null && teamSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

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
                      const SizedBox(height: 16),
                      
                      // On This Day (Throwback)
                      _buildThrowbackSection(context),
                      
                      const SizedBox(height: 24),
                      
                      // 1. Today's Highlight
                      _buildHighlightCard(context, teamId),
                      const SizedBox(height: 24),

                      // 2. Group Chat
                      if (teamId == null)
                        _buildJoinCrewSection(context)
                      else
                        _buildCurrentTeamCard(context, teamData, teamId),
                      const SizedBox(height: 24),

                      // 3. Games
                      _buildSectionHeader(context, "Games"),
                      const SizedBox(height: 16),
                      _buildGamesSection(context),
                      const SizedBox(height: 32),

                      // 4. Time Capsules
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader(context, "Time Capsules"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CapsuleListScreen(groupId: teamId),
                                ),
                              );
                            },
                            child: const Text('View All', style: TextStyle(color: BondBoxColors.primaryPurple)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CapsuleListScreen(groupId: teamId),
                            ),
                          );
                        },
                        child: _buildTimeCapsulesSection(context),
                      ),
                      const SizedBox(height: 32),

                      // 5. Memory Vault
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader(context, "Memory Vault"),
                          if (teamId != null)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MemoryCollectionScreen(groupId: teamId),
                                  ),
                                );
                              },
                              child: const Text('View All', style: TextStyle(color: BondBoxColors.primaryPurple)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          if (teamId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemoryCollectionScreen(groupId: teamId),
                              ),
                            );
                          }
                        },
                        child: _buildMemoryVaultSection(context),
                      ),
                      const SizedBox(height: 24),

                      // Auxiliary Sections (moved to bottom)
                      _buildRedeemSection(context),
                      const SizedBox(height: 24),
                      if (teamId != null) 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: MiniCalendar(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MemoryCollectionScreen(groupId: teamId),
                                ),
                              );
                            },
                          ),
                        ),
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
          Expanded(
            child: Row(
              children: [
                BondAvatar(
                  imageUrl: userData?['avatar'],
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back, $displayName!",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (teamName != null)
                        Text(
                          teamName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: BondBoxColors.primaryPurple, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: BondBoxColors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner_rounded, color: BondBoxColors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
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
          IconButton(
  icon: const Icon(
    Icons.chevron_right_rounded,
    color: BondBoxColors.textSecondary,
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RewardsScreen(),
      ),
    );
  },
)
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
           GestureDetector(
            onTap: () {
               // Navigate to Leaderboard
               final user = FirebaseAuth.instance.currentUser;
               FirebaseFirestore.instance.collection('users').doc(user?.uid).get().then((doc) {
                   final teamId = doc.data()?['currentTeamId'];
                   if (teamId != null) {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardScreen(teamId: teamId)));
                   } else {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Join a crew to see the leaderboard!")));
                   }
               });
            },
            child: const Row(
              children: [
                Text("Rank", style: TextStyle(color: BondBoxColors.primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                Icon(Icons.leaderboard_rounded, color: BondBoxColors.primaryPurple, size: 16),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHighlightCard(BuildContext context, String? teamId) {
    return FadeInUp(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 215),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF818CF8), Color(0xFFC084FC)], // Premium Indigo-Purple
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: BondBoxColors.primaryPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Illustration on the right
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Opacity(
                  opacity: 0.8,
                  child: Image.network(
                    "https://cdni.iconscout.com/illustration/premium/thumb/friends-taking-selfie-illustration-download-in-svg-png-gif-formats--group-photos-hanging-out-friendship-pack-activities-illustrations-4014902.png",
                    width: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(width: 180),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "LIVE NOW",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Today's Highlight",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Text(
                      "Who's most likely to stare group pictures?",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (teamId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DailyPollScreen(teamId: teamId),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Join a crew to vote!")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: BondBoxColors.primaryPurple,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      ),
    );
  }

  Widget _buildThrowbackSection(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _memoryService.getThrowbackMemories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

        final throwbacks = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "On This Day 📸",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: throwbacks.length,
                itemBuilder: (context, index) {
                  final data = throwbacks[index].data() as Map<String, dynamic>;
                  final createdAt = (data['createdAt'] as Timestamp).toDate();
                  final yearDiff = DateTime.now().year - createdAt.year;
                  
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: DecorationImage(
                        image: NetworkImage(data['coverUrl'] ?? "https://picsum.photos/300"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$yearDiff ${yearDiff > 1 ? "Years" : "Year"} Ago",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            data['name'] ?? "Memory",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildJoinCrewSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: BondBoxColors.mint.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: BondBoxColors.mint.withOpacity(0.5), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, 
            bottom: -20,
            child: Icon(Icons.group_add_rounded, size: 120, color: BondBoxColors.mint.withOpacity(0.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Level Up Your Vibe 🚀",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: BondBoxColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join your crew and start collecting memories together.",
                  style: TextStyle(color: BondBoxColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _crewCodeController,
                        decoration: InputDecoration(
                          hintText: "Enter Join Code",
                          hintStyle: const TextStyle(fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          suffixIcon: _isJoining 
                            ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                            : IconButton(onPressed: _joinTeam, icon: const Icon(Icons.arrow_forward_rounded, color: BondBoxColors.primaryPurple)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _createTeam,
                    child: const Text(
                      "Don't have a code? Create Crew",
                      style: TextStyle(color: BondBoxColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('capsules')
          .where('createdBy', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final allDocs = snapshot.data?.docs ?? [];
        // Sort client-side by unlockDate
        allDocs.sort((a, b) {
          final aDate = (a.data() as Map<String, dynamic>)['unlockDate'] as Timestamp?;
          final bDate = (b.data() as Map<String, dynamic>)['unlockDate'] as Timestamp?;
          if (aDate == null || bDate == null) return 0;
          return aDate.compareTo(bDate);
        });
        final capsules = allDocs.take(2).toList();

        if (capsules.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('No capsules yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text('Create your first time capsule!', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
          );
        }

        return Column(
          children: capsules.map((capsule) {
            final data = capsule.data() as Map<String, dynamic>;
            final title = data['title'] ?? 'Untitled Capsule';
            final unlockDate = (data['unlockDate'] as Timestamp).toDate();
            final isUnlocked = data['isUnlocked'] ?? false;
            final contributors = List<String>.from(data['contributors'] ?? []);
            final now = DateTime.now();
            final shouldUnlock = now.isAfter(unlockDate);

            String countdownText;
            if (shouldUnlock || isUnlocked) {
              countdownText = '✨ Unlocked!';
            } else {
              final diff = unlockDate.difference(now);
              if (diff.inDays > 0) {
                countdownText = 'Unlocks in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
              } else if (diff.inHours > 0) {
                countdownText = 'Unlocks in ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}';
              } else {
                countdownText = 'Unlocking soon...';
              }
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
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
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: (shouldUnlock || isUnlocked)
                          ? Colors.amber.withOpacity(0.1)
                          : BondBoxColors.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        (shouldUnlock || isUnlocked) ? '📦' : '🔒',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          countdownText,
                          style: TextStyle(
                            color: (shouldUnlock || isUnlocked) ? Colors.green : BondBoxColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (contributors.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ...contributors.take(3).map((uid) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$uid'),
                                    backgroundColor: Colors.white,
                                  ),
                                );
                              }),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${contributors.length} friend${contributors.length == 1 ? '' : 's'} contributed',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BondBoxColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMemoryVaultSection(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8), // Soft pink background like reference
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "This Week's Recaps",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF831843),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Shareable Moments with Your Crew",
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFBE185D).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFFBE185D), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Horizontal List of Memory Collections
          SizedBox(
            height: 220,
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _memoryService.getMemoryCollections('dummy_group_id'), // Queries by user ID internally now
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final collections = snapshot.data ?? [];
                
                if (collections.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 40, color: Colors.pink[200]),
                        const SizedBox(height: 8),
                        Text(
                          "No memories yet",
                          style: TextStyle(color: Colors.pink[300]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    final data = collection.data() as Map<String, dynamic>;
                    return _buildMemoryCollectionCard(context, collection.id, data);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Create Button
          GestureDetector(
            onTap: () {
               // Initial navigation to collection screen to create new
               // In a real app we might open the dialog directly
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MemoryCollectionScreen(groupId: 'personal'),
                  ),
                );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF472B6), Color(0xFFBE185D)], // Pink gradient
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBE185D).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Color(0xFFBE185D), size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Create New Memory Capsule",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCollectionCard(BuildContext context, String collectionId, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Untitled';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemoryDetailScreen(collectionId: collectionId),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Photo Grid Container
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _memoryService.getMemories(collectionId),
                builder: (context, snapshot) {
                  final memories = snapshot.data ?? [];
                  final photoMemories = memories
                      .where((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return d['mediaUrl'] != null && d['mediaUrl'].toString().isNotEmpty;
                      })
                      .take(4)
                      .toList();
                  
                  if (photoMemories.isEmpty) {
                     return Container(
                       decoration: BoxDecoration(
                         color: Colors.grey[100],
                         borderRadius: BorderRadius.circular(16),
                       ),
                       child: Center(
                         child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[300], size: 30),
                       ),
                     );
                  }

                  // 2x2 Grid logic
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _buildGridImage(photoMemories.isNotEmpty ? (photoMemories[0].data() as Map<String, dynamic>)['mediaUrl'] : null),
                              const SizedBox(width: 2),
                              _buildGridImage(photoMemories.length > 1 ? (photoMemories[1].data() as Map<String, dynamic>)['mediaUrl'] : null),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: Row(
                            children: [
                              _buildGridImage(photoMemories.length > 2 ? (photoMemories[2].data() as Map<String, dynamic>)['mediaUrl'] : null),
                              const SizedBox(width: 2),
                              _buildGridImage(photoMemories.length > 3 ? (photoMemories[3].data() as Map<String, dynamic>)['mediaUrl'] : null),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF831843),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridImage(String? url) {
    return Expanded(
      child: Container(
        color: Colors.grey[100],
        child: url != null
            ? Image.network(url, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
            : Container(), // Empty placeholder
      ),
    );
  }
}
