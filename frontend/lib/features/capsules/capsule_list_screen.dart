import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../service/capsule_service.dart';
import '../../core/theme/bondbox_theme.dart';
import 'create_capsule_screen.dart';
import 'capsule_detail_screen.dart';

class CapsuleListScreen extends StatefulWidget {
  final String? groupId;

  const CapsuleListScreen({super.key, this.groupId});

  @override
  State<CapsuleListScreen> createState() => _CapsuleListScreenState();
}

class _CapsuleListScreenState extends State<CapsuleListScreen> {
  final CapsuleService _capsuleService = CapsuleService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      appBar: AppBar(
        title: const Text('Time Capsules', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: BondBoxColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateCapsuleScreen(groupId: widget.groupId),
            ),
          );
        },
        backgroundColor: BondBoxColors.primaryPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Capsule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _capsuleService.getAllUserCapsules(_currentUserId, widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No capsules yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Create your first time capsule!', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          final capsules = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: capsules.length,
            itemBuilder: (context, index) {
              final capsule = capsules[index];
              final data = capsule.data() as Map<String, dynamic>;
              
              final unlockDate = (data['unlockDate'] as Timestamp).toDate();
              final isUnlocked = data['isUnlocked'] ?? false;
              final shouldUnlock = DateTime.now().isAfter(unlockDate);

              // Auto-unlock if time has passed
              if (shouldUnlock && !isUnlocked) {
                _capsuleService.unlockCapsule(capsule.id, _currentUserId);
              }

              return _buildCapsuleCard(
                context,
                capsule.id,
                data,
                unlockDate,
                shouldUnlock || isUnlocked,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCapsuleCard(
    BuildContext context,
    String capsuleId,
    Map<String, dynamic> data,
    DateTime unlockDate,
    bool isUnlocked,
  ) {
    final title = data['title'] ?? 'Untitled Capsule';
    final mediaUrls = List<String>.from(data['mediaUrls'] ?? []);
    final contributors = List<String>.from(data['contributors'] ?? []);
    final message = data['message'] ?? '';

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CapsuleDetailScreen(capsuleId: capsuleId),
            ),
          );
        } else {
          // Show option to contribute
          _showContributeDialog(capsuleId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? const LinearGradient(
                  colors: [Color(0xFFFEE2E2), Color(0xFFFEF3C7), Color(0xFFDDD6FE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Color(0xFFE0E7FF), Color(0xFFFCE7F3), Color(0xFFDDD6FE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isUnlocked ? Colors.amber.withOpacity(0.2) : Colors.purple.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shimmer effect for locked capsules
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with cute icon
                  Row(
                    children: [
                      // Cute capsule icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            isUnlocked ? '📦' : '🔒',
                            style: const TextStyle(fontSize: 36),
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
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isUnlocked
                                  ? 'Unlocked ${_getTimeAgo(unlockDate)}'
                                  : 'Unlocks ${DateFormat('MMM d, y').format(unlockDate)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.more_vert_rounded,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),

                  if (!isUnlocked && message.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message.length > 50 ? '${message.substring(0, 50)}...' : message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Preview images
                  if (mediaUrls.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: Row(
                        children: mediaUrls.take(3).map((url) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                    ),
                                    if (!isUnlocked)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.lock_rounded,
                                            color: Colors.grey[600],
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  if (mediaUrls.isNotEmpty) const SizedBox(height: 16),

                  // Contributors and countdown
                  Row(
                    children: [
                      // Contributors avatars
                      ...contributors.take(3).map((uid) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$uid'),
                            backgroundColor: Colors.white,
                          ),
                        );
                      }),
                      Text(
                        '${contributors.length} friend${contributors.length == 1 ? '' : 's'} contributed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (!isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: BondBoxColors.primaryPurple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined, size: 14, color: BondBoxColors.primaryPurple),
                              const SizedBox(width: 4),
                              Text(
                                _getCountdown(unlockDate),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: BondBoxColors.primaryPurple,
                                ),
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
      ),
    );
  }

  void _showContributeDialog(String capsuleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Capsule'),
        content: const Text('This capsule is locked. Would you like to add your memories to it?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to contribute screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateCapsuleScreen(
                    groupId: widget.groupId,
                    existingCapsuleId: capsuleId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BondBoxColors.primaryPurple,
            ),
            child: const Text('Add Memories', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getCountdown(DateTime unlockDate) {
    final now = DateTime.now();
    final difference = unlockDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} remaining';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} remaining';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} remaining';
    } else {
      return 'Unlocking soon...';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'just now';
    }
  }
}
