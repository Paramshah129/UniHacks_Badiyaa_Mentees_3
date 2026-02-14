import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/bondbox_theme.dart';

class CapsuleDetailScreen extends StatelessWidget {
  final String capsuleId;

  const CapsuleDetailScreen({super.key, required this.capsuleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      appBar: AppBar(
        title: const Text('Capsule Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: BondBoxColors.background,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('capsules')
            .doc(capsuleId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Capsule not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final title = data['title'] ?? 'Untitled';
          final message = data['message'] ?? '';
          final mediaUrls = List<String>.from(data['mediaUrls'] ?? []);
          final isUnlocked = data['isUnlocked'] ?? false;

          if (!isUnlocked) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'This capsule is still locked',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Come back later to unlock it!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 24),

                // Message
                if (message.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Media gallery
                if (mediaUrls.isNotEmpty) ...[
                  const Text(
                    'Photos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: mediaUrls.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // TODO: Open full-screen image viewer
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(mediaUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
