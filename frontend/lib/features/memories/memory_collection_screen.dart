import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/memory_service.dart';
import '../../core/theme/bondbox_theme.dart';
import 'memory_detail_screen.dart';

class MemoryCollectionScreen extends StatefulWidget {
  final String groupId;

  const MemoryCollectionScreen({super.key, required this.groupId});

  @override
  State<MemoryCollectionScreen> createState() => _MemoryCollectionScreenState();
}

class _MemoryCollectionScreenState extends State<MemoryCollectionScreen> {
  final MemoryService _memoryService = MemoryService();
  final TextEditingController _nameController = TextEditingController();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _createCollection() async {
    if (_nameController.text.isEmpty) return;

    try {
      await _memoryService.createMemoryCollection(
        groupId: widget.groupId,
        name: _nameController.text,
      );
      
      _nameController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ Collection created!'),
            backgroundColor: BondBoxColors.primaryPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '📸 New Memory Collection',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Give your collection a name!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g., Goa Trip 2026 🌴',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: BondBoxColors.primaryPurple, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createCollection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BondBoxColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Create Collection ✨',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3), Color(0xFFE0F2FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.black54),
                              SizedBox(width: 4),
                              Text('Back', style: TextStyle(fontSize: 14, color: Colors.black54)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Memory Vault',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          'Your shared moments ✨',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showCreateDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: BondBoxColors.primaryPurple.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Collections
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: _memoryService.getMemoryCollections(widget.groupId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    final collections = snapshot.data!;

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: collections.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final collection = collections[index];
                        final data = collection.data() as Map<String, dynamic>;
                        return _buildPremiumCollectionCard(context, collection.id, data);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Text('📷', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No memories yet!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a collection and invite friends to share photos! 💕',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Create First Collection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: BondBoxColors.primaryPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCollectionCard(BuildContext context, String collectionId, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Untitled';
    final createdBy = data['createdBy'] ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final isShared = createdBy != _currentUserId;
    
    final dateStr = createdAt != null
        ? '${_monthName(createdAt.toDate().month)} ${createdAt.toDate().day}'
        : '';

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isShared ? Colors.orange[50] : const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isShared ? Icons.group_outlined : Icons.folder_open_rounded,
                      color: isShared ? Colors.orange : BondBoxColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          isShared ? 'Shared Collection' : 'My Collection',
                          style: TextStyle(
                            fontSize: 12,
                            color: isShared ? Colors.orange : Colors.grey[500],
                            fontWeight: isShared ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (dateStr.isNotEmpty)
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                ],
              ),
            ),

            // 2x2 Photo Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: 180, // Large preview
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
                           color: Colors.grey[50],
                           borderRadius: BorderRadius.circular(16),
                         ),
                         child: Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[300], size: 40),
                               const SizedBox(height: 8),
                               Text('No photos yet', style: TextStyle(color: Colors.grey[400])),
                             ],
                           ),
                         ),
                       );
                    }

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
            ),

            // Footer (Avatars + Count)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Overlapping avatars
                  SizedBox(
                    width: 60,
                    height: 24,
                    child: Stack(
                      children: [
                        _buildAvatar(0, createdBy),
                        // In a real app we'd fetch other contributors
                        if (isShared) _buildAvatar(16, null), 
                      ],
                    ),
                  ),
                  const Spacer(),
                  StreamBuilder<List<DocumentSnapshot>>(
                    stream: _memoryService.getMemories(collectionId),
                    builder: (context, snap) {
                      final count = snap.data?.length ?? 0;
                      return Text(
                        '$count moments',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(double left, String? uid) {
    return Positioned(
      left: left,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: CircleAvatar(
          radius: 10,
          backgroundImage: uid != null 
              ? NetworkImage('https://i.pravatar.cc/150?u=$uid') 
              : const NetworkImage('https://i.pravatar.cc/150?u=friend'),
          backgroundColor: Colors.grey[200],
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
            : Container(),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
