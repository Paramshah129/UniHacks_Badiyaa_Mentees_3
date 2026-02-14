import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../service/memory_service.dart';
import '../../core/theme/bondbox_theme.dart';
import 'memory_detail_screen.dart';
import 'widgets/album_calendar.dart';
import 'widgets/album_filter_tabs.dart';
import 'widgets/album_card.dart';

class MemoryCollectionScreen extends StatefulWidget {
  final String groupId;

  const MemoryCollectionScreen({super.key, required this.groupId});

  @override
  State<MemoryCollectionScreen> createState() => _MemoryCollectionScreenState();
}

class _MemoryCollectionScreenState extends State<MemoryCollectionScreen> {
  final MemoryService _memoryService = MemoryService();
  final TextEditingController _nameController = TextEditingController();
  
  // Filters & State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedFilter = 'All';

  // Creation State
  String _selectedCategory = 'Trips';
  String _selectedMood = 'Happy';
  bool _isPrivate = false;
  DateTime _creationDate = DateTime.now();

  final List<String> _categories = ['Trips', 'Outings', 'Events', 'Private', 'Shared'];
  final List<String> _moods = ['Happy', 'Crazy', 'Emotional', 'Chill', 'Romantic'];

  Future<void> _createCollection() async {
    if (_nameController.text.isEmpty) return;

    try {
      await _memoryService.createMemoryCollection(
        groupId: widget.groupId,
        name: _nameController.text,
        category: _selectedCategory,
        mood: _selectedMood,
        isPrivate: _isPrivate,
        date: _creationDate,
      );
      
      _nameController.clear();
      // Reset defaults
      setState(() {
         _selectedCategory = 'Trips';
         _selectedMood = 'Happy';
         _isPrivate = false;
         _creationDate = DateTime.now();
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Collection created'),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
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
                  'New Memory Collection',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Name (e.g., Goa Trip 2026)',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Category",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setModalState(() => _selectedCategory = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMood,
                        decoration: InputDecoration(
                          labelText: "Mood",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        items: _moods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) => setModalState(() => _selectedMood = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date Picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _creationDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() => _creationDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          "${_creationDate.day}/${_creationDate.month}/${_creationDate.year}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Privacy Switch
                SwitchListTile(
                  title: const Text("Private Collection"),
                  value: _isPrivate,
                  onChanged: (val) => setModalState(() => _isPrivate = val),
                  activeColor: BondBoxColors.primaryPurple,
                  contentPadding: EdgeInsets.zero,
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
                      elevation: 0,
                    ),
                    child: const Text(
                      'Create Collection',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
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
            children: [
              // 1. Header (Custom App Bar)
               Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
                    ),
                    const Text(
                      "Shared Memories ✨",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: _showCreateDialog,
                       child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.add, color: BondBoxColors.primaryPurple),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Scrollable Content
              // 2. Scrollable Content
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: _memoryService.getMemoryCollections(widget.groupId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                       return const Center(child: CircularProgressIndicator());
                    }
                    
                    final allCollections = snapshot.data ?? [];

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Calendar
                          AlbumCalendar(
                            focusedDay: _focusedDay,
                            selectedDay: _selectedDay,
                            onDaySelected: (selected, focused) {
                              setState(() {
                                _selectedDay = selected;
                                _focusedDay = focused;
                              });
                            },
                            albums: allCollections, 
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Filter Tabs
                          AlbumFilterTabs(
                            selectedFilter: _selectedFilter,
                            onFilterSelected: (filter) => setState(() => _selectedFilter = filter),
                          ),

                          const SizedBox(height: 24),

                          // Album List
                          Builder(
                            builder: (context) {
                              var filteredCollections = allCollections;
                              
                          // Filter Logic
                          if (_selectedFilter != 'All') {
                             filteredCollections = filteredCollections.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final category = data['category'] as String?;
                                final isPrivate = data['isPrivate'] == true;
                                
                                // Map filter text to category/logic
                                if (_selectedFilter == 'Trips' && category?.contains('Trips') == true) return true;
                                if (_selectedFilter == 'Outings' && category?.contains('Outings') == true) return true;
                                if (_selectedFilter == 'Events' && category?.contains('Events') == true) return true;
                                if (_selectedFilter == 'Private' && isPrivate) return true;
                                if (_selectedFilter == 'Shared' && !isPrivate && category?.contains('Shared') == true) return true;
                                
                                // Fallback
                                if (category != null && category.contains(_selectedFilter)) return true;

                                return false; 
                             }).toList();
                          }
                              
                              // Date Filter Logic
                              if (_selectedDay != null) {
                                 filteredCollections = filteredCollections.where((doc) {
                                    final createdAt = (doc.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                                    if (createdAt == null) return false;
                                    final date = createdAt.toDate();
                                    return isSameDay(date, _selectedDay);
                                 }).toList();
                              }

                              if (filteredCollections.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    children: [
                                      const Text("No albums found here!", style: TextStyle(color: Colors.grey)),
                                      if (_selectedDay != null)
                                         TextButton(onPressed: () => setState(() => _selectedDay = null), child: const Text("Clear Date Filter")),
                                    ],
                                  ),
                                );
                              }

                              return ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: filteredCollections.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final doc = filteredCollections[index];
                                  return AlbumCard(
                                    collectionId: doc.id,
                                    data: doc.data() as Map<String, dynamic>,
                                    onTap: () {
                                       Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MemoryDetailScreen(collectionId: doc.id),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          ),
                          const SizedBox(height: 80), 
                        ],
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper for date comparison (duplicated from table_calendar to avoid import if not exported)
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
