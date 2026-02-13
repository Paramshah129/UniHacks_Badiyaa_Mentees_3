import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/chat_service.dart';
import '../../core/theme/bondbox_theme.dart';

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

  await _chatService.sendTeamMessage(
      widget.teamId, _messageController.text.trim());

  _chatService.updateTypingStatus(widget.teamId, false);

  _messageController.clear();

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
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundImage: data['senderAvatar'] != null
                                      ? NetworkImage(data['senderAvatar'])
                                      : null,
                                  backgroundColor: BondBoxColors.primaryPurple.withOpacity(0.2),
                                  child: data['senderAvatar'] == null
                                      ? Text(
                                          (data['senderName'] ?? "U")[0].toUpperCase(),
                                          style: const TextStyle(
                                              color: BondBoxColors.primaryPurple,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : null,
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
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline_rounded, color: BondBoxColors.primaryPurple)),
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
}
