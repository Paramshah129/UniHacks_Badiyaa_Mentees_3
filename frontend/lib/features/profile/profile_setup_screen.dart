import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/bondbox_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../auth/add_friends.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _bioController = TextEditingController();

  String? _selectedAvatar;

  final List<String> _avatars = [
    "assets/avatars/avatar1.jpeg",
    "assets/avatars/avatar2.jpeg",
    "assets/avatars/avatar3.jpeg",
    "assets/avatars/avatar4.jpeg",
    "assets/avatars/avatar5.jpeg",
    "assets/avatars/avatar6.jpeg",
    "assets/avatars/avatar7.jpeg",
    "assets/avatars/avatar8.jpeg",
  ];

  Future<void> _saveProfile() async {
    if (_selectedAvatar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an avatar")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({
      'bio': _bioController.text.trim(),
      'avatar': _selectedAvatar,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AddFriendScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondBoxColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile Setup",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                "Choose your avatar and write your bio.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BondBoxColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // 🔹 Bio Field
              _buildBioField(),

              const SizedBox(height: 48),

              const Text(
                "Choose your Avatar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 20),

              _buildAvatarGrid(),

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BondBoxColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Launch Experience",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bio",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "What's your deal?",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _avatars.length,
      itemBuilder: (context, index) {
        final avatar = _avatars[index];
        final isSelected = _selectedAvatar == avatar;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAvatar = avatar;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? BondBoxColors.primaryPurple
                    : Colors.transparent,
                width: 3,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: BondAvatar(
              radius: 40,
              imageUrl: avatar,
            ),
          ),
        );
      },
    );
  }
}