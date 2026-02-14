import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:friendsconnect/core/theme/bondbox_theme.dart';
import 'package:friendsconnect/shared/widgets/shared_widgets.dart';
import '../navigation/main_navigation_screen.dart';
import '../../service/user_service.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final suggestions = await _userService.getSuggestions();
    setState(() => _suggestions = suggestions);
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _userService.searchUsers(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Premium Background Gradient with organic shapes
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF1F1), Color(0xFFFFE4E1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Bubbles/Organic Shapes for aesthetic
          Positioned(
            top: -100,
            left: -50,
            child: _buildBubble(300, Colors.pink.withOpacity(0.05)),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBubble(250, Colors.purple.withOpacity(0.05)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "Connect With Your Crew",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.brown[800],
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "The more, the merrier! 🎉",
                            style: TextStyle(color: Colors.brown[400], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Search Bar
                  _buildSearchBar(),
                  
                  const SizedBox(height: 32),
                  
                  // Search Results (Directly below search bar if searching)
                  if (_searchResults.isNotEmpty || _isSearching) ...[
                    _buildGlassyContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubheader("Find People"),
                          const SizedBox(height: 12),
                          if (_isSearching)
                            const Center(child: CircularProgressIndicator())
                          else
                            ..._searchResults.map((user) => _buildUserListItem(
                              name: "@${user['nickname']}",
                              subtitle: user['fullName'] ?? "New Viber",
                              avatarUrl: user['avatar'],
                              action: _buildActionButton(
                                "Add Friend", 
                                Icons.add_circle_outline, 
                                Colors.pink[200]!,
                                onTap: () async {
                                  await _userService.addFriendDirectly(user['uid']);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Connected with @${user['nickname']}! ✨"),
                                        backgroundColor: Colors.pink[200],
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                              ),
                            )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Main Content Card (Requests & Suggestions)
                  _buildGlassyContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitleWithIcon("Crew Connection", Icons.front_hand_rounded),
                        const SizedBox(height: 20),
                        
                        _buildSubheader("Pending Requests"),
                        const SizedBox(height: 12),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _userService.getPendingRequests(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text("No requests right now", style: TextStyle(color: Colors.brown[300], fontSize: 13, fontStyle: FontStyle.italic)),
                              );
                            }
                            return Column(
                              children: snapshot.data!.map((req) => _buildUserListItem(
                                name: "@${req['nickname']}",
                                subtitle: "Wants to vibe with you!",
                                avatarUrl: req['avatar'],
                                action: _buildActionButton(
                                  "Accept", 
                                  Icons.check_circle_outline, 
                                  Colors.green[200]!,
                                  onTap: () => _userService.acceptFriendRequest(req['requestId'], req['fromUid']),
                                ),
                              )).toList(),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        _buildSubheader("Suggestions For You"),
                        const SizedBox(height: 12),
                        if (_suggestions.isEmpty)
                           Text("Scanning for vibers...", style: TextStyle(color: Colors.brown[300], fontSize: 13))
                        else
                          ..._suggestions.map((user) => _buildUserListItem(
                            name: "@${user['nickname']}",
                            subtitle: "Mutual interest in chaos",
                            avatarUrl: user['avatar'],
                            action: _buildActionButton(
                              "Vibe Check", 
                              Icons.add_circle_outline, 
                              Colors.pink[200]!,
                              onTap: () async {
                                await _userService.addFriendDirectly(user['uid']);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Vibing with @${user['nickname']}! 🚀"),
                                      backgroundColor: Colors.pink[200],
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),
                          )),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Continue Button
                  FadeInUp(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BondBoxColors.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 8,
                          shadowColor: BondBoxColors.primaryPurple.withOpacity(0.4),
                        ),
                        child: const Text("Launch Experience 🚀", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Star Icon at bottom right as per image
          Positioned(
            bottom: 30,
            right: 30,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.star_rounded, size: 80, color: Colors.brown[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSearchBar() {
    return FadeIn(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.brown[300]),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Find friends by username or code",
                  hintStyle: TextStyle(color: Colors.brown[300], fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.brown[100]?.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_open_rounded, color: Colors.brown[800], size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitleWithIcon(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.brown[800],
            ),
          ),
          Icon(icon, color: Colors.brown[200], size: 24),
        ],
      ),
    );
  }

  Widget _buildSubheader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.brown[800],
      ),
    );
  }

  Widget _buildUserListItem({
    required String name,
    required String subtitle,
    String? avatarUrl,
    required Widget action,
  }) {
    return FadeInLeft(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            BondAvatar(
              imageUrl: avatarUrl,
              radius: 25,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.brown[800],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.brown[300],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            action,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassyContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withOpacity(0.2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
