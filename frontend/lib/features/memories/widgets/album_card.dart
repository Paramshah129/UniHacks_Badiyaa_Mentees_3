
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/bondbox_theme.dart';
import '../../../../service/memory_service.dart';

class AlbumCard extends StatelessWidget {
  final String collectionId;
  final Map<String, dynamic> data;
  final Function() onTap;

  const AlbumCard({
    super.key,
    required this.collectionId,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Untitled';
    final createdAt = data['createdAt'] as Timestamp?;
    final date = createdAt?.toDate();
    final day = date?.day.toString() ?? '??';
    final month = _monthName(date?.month ?? 1);
    final weekday = _weekdayName(date?.weekday ?? 1);
    
    // Default mood/category if not present (backward compatibility)
    final mood = data['mood'] ?? 'Happy';
    final category = data['category'] ?? 'General';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Date & Avatar
              Column(
                children: [
                   Text(
                    day,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: BondBoxColors.textPrimary,
                    ),
                  ),
                  Text(
                    "$month/$weekday",
                    style: const TextStyle(
                      fontSize: 12,
                      color: BondBoxColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=me'), 
                    // Ideally fetch user avatar, but using placeholder for "me"
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Right: Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                             Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: BondBoxColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                             ),
                             if(data['isPrivate'] == true)
                                const Icon(Icons.lock_rounded, size: 14, color: Colors.grey),
                        ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Thumbnails (3 max)
                    SizedBox(
                      height: 80,
                      child: StreamBuilder<List<DocumentSnapshot>>(
                        stream: MemoryService().getMemories(collectionId), // This might be heavy per card, optimization for later: fetch count/preview in collection doc
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                                child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
                            );
                          }
                          
                          final photos = snapshot.data!
                              .where((doc) => (doc.data() as Map<String, dynamic>)['mediaUrl'] != null)
                              .take(3)
                              .toList();
                          
                          if (photos.isEmpty) return const SizedBox();

                          return Row(
                            children: photos.map((photo) {
                                final url = (photo.data() as Map<String, dynamic>)['mediaUrl'];
                                return Expanded(
                                    child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                                        ),
                                    ),
                                );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Footer: Mood + Count
                    Row(
                      children: [
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: Colors.amber.withOpacity(0.2),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Text(
                             mood, 
                             style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                           ),
                        ),
                        const Spacer(),
                         StreamBuilder<List<DocumentSnapshot>>(
                            stream: MemoryService().getMemories(collectionId),
                            builder: (context, snapshot) {
                                final count = snapshot.data?.length ?? 0;
                                return Text(
                                  "$count photos", 
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                );
                            }
                         ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
