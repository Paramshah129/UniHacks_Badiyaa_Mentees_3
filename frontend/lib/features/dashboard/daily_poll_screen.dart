import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/bondbox_theme.dart';

class DailyPollScreen extends StatefulWidget {
  final String teamId;
  const DailyPollScreen({super.key, required this.teamId});

  @override
  State<DailyPollScreen> createState() => _DailyPollScreenState();
}

class _DailyPollScreenState extends State<DailyPollScreen> {
  String? _selectedUserId;
  bool _hasVoted = false;

  void _submitVote() {
    if (_selectedUserId != null) {
      setState(() {
        _hasVoted = true;
      });
      // Here you would normally send the vote to Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: BondBoxColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Daily Poll",
          style: TextStyle(
            color: BondBoxColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('teams').doc(widget.teamId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final teamData = snapshot.data!.data() as Map<String, dynamic>?;
          final playerIds = List<String>.from(teamData?['players'] ?? []);

          if (playerIds.isEmpty) {
            return const Center(child: Text("No players in this crew yet!"));
          }

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: playerIds)
                .get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final players = userSnapshot.data!.docs.map((doc) => {
                'id': doc.id,
                'name': (doc.data() as Map<String, dynamic>)['nickname'] ?? (doc.data() as Map<String, dynamic>)['fullName'] ?? "Player",
                'avatar': (doc.data() as Map<String, dynamic>)['photoUrl'] ?? "https://i.pravatar.cc/150",
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Who is the most likely to get lost in their own house?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: BondBoxColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!_hasVoted) 
                      _buildSelector(players)
                    else
                      _buildResults(players),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: !_hasVoted ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: _selectedUserId == null ? null : _submitVote,
            style: ElevatedButton.styleFrom(
              backgroundColor: BondBoxColors.primaryPurple,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text("Submit Vote"),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildSelector(List<Map<String, dynamic>> players) {
    return Column(
      children: players.map((player) {
        final isSelected = _selectedUserId == player['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedUserId = player['id']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? BondBoxColors.primaryPurple : Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(player['avatar']!),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    player['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BondBoxColors.textPrimary,
                    ),
                  ),
                ),
                Radio<String>(
                  value: player['id']!,
                  groupValue: _selectedUserId,
                  activeColor: BondBoxColors.primaryPurple,
                  onChanged: (val) => setState(() => _selectedUserId = val),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResults(List<Map<String, dynamic>> players) {
    return Column(
      children: players.map((player) {
        final percentage = 0.25; 
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(player['avatar']!),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    player['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${(percentage * 100).toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BondBoxColors.primaryPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [BondBoxColors.primaryPurple, BondBoxColors.secondaryPink],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
