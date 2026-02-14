
import 'package:flutter/material.dart';
import '../../../../core/theme/bondbox_theme.dart';

class AlbumFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const AlbumFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final List<String> filters = const [
    'All',
    'Trips',
    'Outings',
    'Events',
    'Private',
    'Shared',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return ChoiceChip(
            label: Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : BondBoxColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onFilterSelected(filter),
            selectedColor: BondBoxColors.primaryPurple,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? BondBoxColors.primaryPurple : Colors.grey[200]!,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: isSelected ? 4 : 0,
            shadowColor: BondBoxColors.primaryPurple.withOpacity(0.3),
          );
        },
      ),
    );
  }
}
