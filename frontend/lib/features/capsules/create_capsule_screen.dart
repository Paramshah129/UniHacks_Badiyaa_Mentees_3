import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../service/capsule_service.dart';
import '../../core/theme/bondbox_theme.dart';

class CreateCapsuleScreen extends StatefulWidget {
  final String? groupId;
  final String? existingCapsuleId;

  const CreateCapsuleScreen({super.key, this.groupId, this.existingCapsuleId});

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final CapsuleService _capsuleService = CapsuleService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  DateTime? _selectedDate;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  bool _isPrivate = true;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickImages() async {
    final images = await _capsuleService.pickImages();
    setState(() {
      _selectedImages = images;
    });
  }

  Future<void> _createCapsule() async {
    // If contributing to existing capsule
    if (widget.existingCapsuleId != null) {
      await _contributeToExisting();
      return;
    }

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an unlock date')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload images first
      final mediaUrls = <String>[];
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      for (final image in _selectedImages) {
        final url = await _capsuleService.uploadCapsuleMedia(
          File(image.path),
          tempId,
        );
        mediaUrls.add(url);
      }

      // Create capsule with media URLs
      await _capsuleService.createCapsule(
        title: _titleController.text,
        message: _messageController.text,
        unlockDate: _selectedDate!,
        mediaUrls: mediaUrls,
        groupId: _isPrivate ? null : widget.groupId,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Capsule created! 🎉 +10 XP'),
            backgroundColor: Colors.green,
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

  Future<void> _contributeToExisting() async {
    if (_messageController.text.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a message or photos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload images
      final mediaUrls = <String>[];
      for (final image in _selectedImages) {
        final url = await _capsuleService.uploadCapsuleMedia(
          File(image.path),
          widget.existingCapsuleId!,
        );
        mediaUrls.add(url);
      }

      // Contribute to capsule
      await _capsuleService.contributeToCapsule(
        widget.existingCapsuleId!,
        _messageController.text,
        mediaUrls,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory added! 🎉 +5 XP'),
            backgroundColor: Colors.green,
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
      backgroundColor: BondBoxColors.background,
      appBar: AppBar(
        title: Text(
          widget.existingCapsuleId != null ? 'Add to Capsule' : 'Create Time Capsule',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: BondBoxColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field (only for new capsules)
            if (widget.existingCapsuleId == null) ...[
              const Text('Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Chaos Crew \'23',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Message field
            const Text('Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write a message to your future self...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Unlock date picker (only for new capsules)
            if (widget.existingCapsuleId == null) ...[
              const Text('Unlock Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: BondBoxColors.primaryPurple),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Select unlock date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
              const SizedBox(height: 24),
            ],

            // Image picker
            const Text('Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_photo_alternate_rounded, color: BondBoxColors.primaryPurple),
                    const SizedBox(width: 12),
                    Text(
                      _selectedImages.isEmpty
                          ? 'Add photos'
                          : '${_selectedImages.length} photo${_selectedImages.length == 1 ? '' : 's'} selected',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Visibility toggle
            if (widget.groupId != null) ...[
              const Text('Visibility', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPrivate = true),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isPrivate ? BondBoxColors.primaryPurple : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Private',
                            style: TextStyle(
                              color: _isPrivate ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPrivate = false),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: !_isPrivate ? BondBoxColors.primaryPurple : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Group',
                            style: TextStyle(
                              color: !_isPrivate ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createCapsule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BondBoxColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                     : Text(
                        widget.existingCapsuleId != null ? 'Add Memories' : 'Create Capsule',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
