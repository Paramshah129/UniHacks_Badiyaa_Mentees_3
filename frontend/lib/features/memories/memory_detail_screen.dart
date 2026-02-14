import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../service/memory_service.dart';
import '../../core/theme/bondbox_theme.dart';

class MemoryDetailScreen extends StatefulWidget {
  final String collectionId;

  const MemoryDetailScreen({super.key, required this.collectionId});

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final MemoryService _memoryService = MemoryService();
  final TextEditingController _textController = TextEditingController();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  XFile? _selectedImage;
  bool _showPhotoGrid = true;

  Future<void> _pickImage() async {
    final image = await _memoryService.pickImage();
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _addMemory() async {
    if (_textController.text.isEmpty && _selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? mediaUrl;
      
      if (_selectedImage != null) {
        final memoryId = DateTime.now().millisecondsSinceEpoch.toString();
        mediaUrl = await _memoryService.uploadMemoryMedia(
          File(_selectedImage!.path),
          memoryId,
        );
      }

      await _memoryService.addMemory(
        collectionId: widget.collectionId,
        text: _textController.text,
        mediaUrl: mediaUrl,
      );

      _textController.clear();
      setState(() {
        _selectedImage = null;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Memory added! 🎉 +5 XP'),
            backgroundColor: BondBoxColors.primaryPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3), Color(0xFFEFF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Memories',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Toggle view
                    GestureDetector(
                      onTap: () => setState(() => _showPhotoGrid = !_showPhotoGrid),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _showPhotoGrid ? Icons.grid_view_rounded : Icons.view_list_rounded,
                          size: 20,
                          color: BondBoxColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Memories
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: _memoryService.getMemories(widget.collectionId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    final memories = snapshot.data!;

                    if (_showPhotoGrid) {
                      return _buildPhotoGrid(memories);
                    } else {
                      return _buildListView(memories);
                    }
                  },
                ),
              ),

              // Input bar
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Text('🌟', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No memories yet!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add photos and notes below 📸',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<DocumentSnapshot> memories) {
    // Separate photo vs text-only memories  
    final photoMemories = memories.where((doc) {
      final d = doc.data() as Map<String, dynamic>;
      return d['mediaUrl'] != null && d['mediaUrl'].toString().isNotEmpty;
    }).toList();
    
    final textMemories = memories.where((doc) {
      final d = doc.data() as Map<String, dynamic>;
      return d['mediaUrl'] == null || d['mediaUrl'].toString().isEmpty;
    }).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo grid
          if (photoMemories.isNotEmpty) ...[
            Row(
              children: [
                const Text('📸', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Photos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                const Spacer(),
                Text(
                  '${photoMemories.length} photo${photoMemories.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: photoMemories.length,
              itemBuilder: (context, index) {
                final doc = photoMemories[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildPhotoCard(doc.id, data);
              },
            ),
          ],

          if (photoMemories.isNotEmpty && textMemories.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),

          // Text memories
          if (textMemories.isNotEmpty) ...[
            Row(
              children: [
                const Text('💭', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...textMemories.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildTextMemoryCard(doc.id, data);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String memoryId, Map<String, dynamic> data) {
    final text = data['text'] ?? '';
    final mediaUrl = data['mediaUrl'];
    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final createdAt = data['createdAt'] as Timestamp?;

    return GestureDetector(
      onTap: () => _showFullImage(memoryId, data),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                ),
              ),
              // Gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (text.isNotEmpty)
                        Text(
                          text.length > 30 ? '${text.substring(0, 30)}...' : text,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (createdAt != null)
                        Text(
                          _formatDate(createdAt.toDate()),
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ),
              // Reaction indicator
              if (reactions.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...reactions.values.toSet().take(3).map((emoji) => Text(emoji.toString(), style: const TextStyle(fontSize: 12))),
                        if (reactions.length > 1) Text(' ${reactions.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextMemoryCard(String memoryId, Map<String, dynamic> data) {
    final text = data['text'] ?? '';
    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final userId = data['userId'] ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final isMyMemory = userId == _currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$userId'),
              ),
              const SizedBox(width: 8),
              Text(
                isMyMemory ? 'You' : 'Friend',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              if (createdAt != null)
                Text(
                  _formatDate(createdAt.toDate()),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 12),
          // Inline reactions
          Row(
            children: [
              _buildReactionChip(memoryId, '❤️', reactions),
              const SizedBox(width: 6),
              _buildReactionChip(memoryId, '😂', reactions),
              const SizedBox(width: 6),
              _buildReactionChip(memoryId, '🔥', reactions),
              const SizedBox(width: 6),
              _buildReactionChip(memoryId, '😍', reactions),
              const SizedBox(width: 6),
              _buildReactionChip(memoryId, '😢', reactions),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<DocumentSnapshot> memories) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        final data = memory.data() as Map<String, dynamic>;
        return _buildFullMemoryCard(memory.id, data);
      },
    );
  }

  Widget _buildFullMemoryCard(String memoryId, Map<String, dynamic> data) {
    final text = data['text'] ?? '';
    final mediaUrl = data['mediaUrl'];
    final userId = data['userId'] ?? '';
    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final isMyMemory = userId == _currentUserId;
    final createdAt = data['createdAt'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$userId'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMyMemory ? 'You' : 'Friend',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (createdAt != null)
                      Text(
                        _formatDate(createdAt.toDate()),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Photo
          if (mediaUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  mediaUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),
            ),

          // Text
          if (text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
            ),

          // Reactions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Row(
              children: [
                _buildReactionChip(memoryId, '❤️', reactions),
                const SizedBox(width: 6),
                _buildReactionChip(memoryId, '😂', reactions),
                const SizedBox(width: 6),
                _buildReactionChip(memoryId, '🔥', reactions),
                const SizedBox(width: 6),
                _buildReactionChip(memoryId, '😍', reactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionChip(String memoryId, String emoji, Map<String, dynamic> reactions) {
    final hasReacted = reactions[_currentUserId] == emoji;
    final count = reactions.values.where((e) => e == emoji).length;

    return GestureDetector(
      onTap: () {
        _memoryService.addReaction(memoryId: memoryId, emoji: emoji);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: hasReacted ? BondBoxColors.primaryPurple.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasReacted ? BondBoxColors.primaryPurple.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            if (count > 0) ...[
              const SizedBox(width: 3),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: hasReacted ? BondBoxColors.primaryPurple : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFullImage(String memoryId, Map<String, dynamic> data) {
    final text = data['text'] ?? '';
    final mediaUrl = data['mediaUrl'];
    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final createdAt = data['createdAt'] as Timestamp?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Image.network(mediaUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (text.isNotEmpty)
                    Text(text, style: const TextStyle(fontSize: 16, height: 1.5)),
                  if (createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _formatDate(createdAt.toDate()),
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildReactionChip(memoryId, '❤️', reactions),
                      const SizedBox(width: 6),
                      _buildReactionChip(memoryId, '😂', reactions),
                      const SizedBox(width: 6),
                      _buildReactionChip(memoryId, '🔥', reactions),
                      const SizedBox(width: 6),
                      _buildReactionChip(memoryId, '😍', reactions),
                      const SizedBox(width: 6),
                      _buildReactionChip(memoryId, '😢', reactions),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null) ...[
            Stack(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: FileImage(File(_selectedImage!.path)),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              // Photo button
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDDD6FE), Color(0xFFFCE7F3)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF8B5CF6), size: 22),
                ),
              ),
              const SizedBox(width: 10),
              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Add a memory... 💭',
                      hintStyle: TextStyle(fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Send button
              _isLoading
                  ? const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                    )
                  : GestureDetector(
                      onTap: _addMemory,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: BondBoxColors.primaryPurple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
