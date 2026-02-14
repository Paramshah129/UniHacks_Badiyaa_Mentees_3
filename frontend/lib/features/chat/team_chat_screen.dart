import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/chat_service.dart';
import '../../service/leaderboard_service.dart';
import '../../core/theme/bondbox_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../games/telepathy_game.dart';
import '../games/desi_song.dart';

class TeamChatScreen extends StatefulWidget {
  final String teamId;
  final String teamName;

  const TeamChatScreen({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final msg = _messageController.text.trim();
    _messageController.clear();
    
    // Send message
    await _chatService.sendTeamMessage(widget.teamId, msg);

    // Award XP (using poll_vote as placeholder for now as per previous logic)
    LeaderboardService().awardActivityPoints(_currentUserId, 'poll_vote');

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.teamName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text("Crew Chat", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
           IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline_rounded)),
        ],
      ),
      body: Column(
        children: [
          
                        Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getTeamMessages(widget.teamId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text("No messages yet. Start the vibe!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == _currentUserId;
                    
                    return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            // 👤 Avatar (Only show for others)
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: BondAvatar(
                                  radius: 18,
                                  imageUrl: data['senderAvatar'],
                                ),
                              ),

                            // 💬 Message Bubble + Name
                            Column(
                              crossAxisAlignment:
                                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      data['senderName'] ?? "Unknown",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width * 0.65),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? BondBoxColors.primaryPurple
                                        : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: isMe
                                          ? const Radius.circular(20)
                                          : const Radius.circular(4),
                                      bottomRight: isMe
                                          ? const Radius.circular(4)
                                          : const Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    data['text'] ?? "",
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : BondBoxColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                  },
                );
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('teams')
      .doc(widget.teamId)
      .collection('typingStatus')
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const SizedBox();

    final typingUsers = snapshot.data!.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return doc.id != _currentUserId &&
             data['isTyping'] == true;
    }).toList();

    if (typingUsers.isEmpty) return const SizedBox();

    final names = typingUsers
        .map((doc) =>
            (doc.data() as Map<String, dynamic>)['senderName'] ?? "Someone")
        .join(", ");

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        "$names is typing...",
        style: const TextStyle(
          fontSize: 16, // 🔥 bigger text
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    );
  },
),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _showGameLauncher(context),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: BondBoxColors.primaryPurple),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: BondBoxColors.offWhite,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) {
                        _chatService.updateTypingStatus(widget.teamId, value.isNotEmpty);
                      },
                      onSubmitted: (_) {
                        _chatService.updateTypingStatus(widget.teamId, false);
                        _sendMessage();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: BondBoxColors.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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

  void _showGameLauncher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Start a Game 🎮",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildGameItem(
                    context,
                    "Fest Fiasco",
                    Icons.psychology_alt_rounded,
                    BondBoxColors.primaryPurple,
                    const FestFiascoScreen(),
                  ),
                  _buildGameItem(
                    context,
                    "Desi Songs",
                    Icons.music_note_rounded,
                    BondBoxColors.secondaryPink,
                    const DesiSongTelepathyScreen(),
                  ),
                  _buildGameItem(
                    context,
                    "Meme Battle",
                    Icons.image_rounded,
                    BondBoxColors.accentBlue,
                    null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGameItem(BuildContext context, String name, IconData icon, Color color, Widget? screen) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (screen != null) {
          _sendGameInvite(name);
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Coming soon!")),
          );
        }
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _sendGameInvite(String gameName) async {
    final msg = "🎮 I've started a game of $gameName! Tap to join the fun!";
    await _chatService.sendTeamMessage(widget.teamId, msg);
  }
}
