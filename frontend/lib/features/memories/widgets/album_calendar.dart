
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AlbumCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<DocumentSnapshot> albums;

  const AlbumCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.albums,
  });

  @override
  State<AlbumCalendar> createState() => _AlbumCalendarState();
}

class _AlbumCalendarState extends State<AlbumCalendar> {
  // Pastel Palette
  final Color _lavender = const Color(0xFFC9B6FF);
  final Color _softPink = const Color(0xFFFFD6E8);
  final Color _softPeach = const Color(0xFFFFE5D0);
  final Color _textPrimary = const Color(0xFF2E2E3A);
  final Color _textSecondary = const Color(0xFF7C7C8A);

  Map<String, dynamic>? _getAlbumForDay(DateTime day) {
    final dayAlbums = widget.albums.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'] as Timestamp?;
      if (createdAt == null) return false;
      final date = createdAt.toDate();
      return isSameDay(date, day);
    }).toList();

    if (dayAlbums.isEmpty) return null;

    final firstAlbumData = dayAlbums.first.data() as Map<String, dynamic>;
    return {
      ...firstAlbumData,
      'count': dayAlbums.length,
      'coverUrl': firstAlbumData['coverUrl'], 
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF), // Very soft white/lavender tint
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _lavender.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2), // Gentle border
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: widget.focusedDay,
          selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
          onDaySelected: widget.onDaySelected,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextFormatter: (date, locale) => 
                "${_monthName(date.month)} ${date.year} ✨", // Added sparkle
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 18, 
              fontWeight: FontWeight.w600, 
              color: _textPrimary,
            ),
            leftChevronIcon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: _textSecondary),
            rightChevronIcon: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: _textSecondary),
            headerPadding: const EdgeInsets.only(bottom: 20),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: GoogleFonts.poppins(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
            weekendStyle: GoogleFonts.poppins(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: GoogleFonts.poppins(color: _textPrimary),
            weekendTextStyle: GoogleFonts.poppins(color: _textPrimary),
            todayDecoration: BoxDecoration(
              color: _lavender.withOpacity(0.2), 
              shape: BoxShape.circle,
            ),
            todayTextStyle: GoogleFonts.poppins(color: _textPrimary, fontWeight: FontWeight.bold),
          ),
          calendarBuilders: CalendarBuilders(
            prioritizedBuilder: (context, day, focusedDay) {
              final albumData = _getAlbumForDay(day);
              final isSelected = isSameDay(day, widget.selectedDay);
              final isToday = isSameDay(day, DateTime.now());
              
              Widget? backgroundWidget;
              Color textColor = _textPrimary;
              
              // 1. Determine Background
              if (albumData != null) {
                if (albumData['coverUrl'] != null) {
                   // IMAGE PREVIEW
                   backgroundWidget = Container(
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(color: _softPink.withOpacity(0.5), width: 2), // Subtle ring
                     ),
                     child: ClipOval(
                       child: Stack(
                         fit: StackFit.expand,
                         children: [
                           Image.network(
                             albumData['coverUrl'],
                             fit: BoxFit.cover,
                             errorBuilder: (_,__,___) => Container(color: _softPeach),
                           ),
                           // Soft light overlay for readability
                           Container(color: Colors.white.withOpacity(0.35)),
                         ],
                       ),
                     ),
                   );
                   textColor = _textPrimary; // Keeping text dark for "chic" look, verified against overlay
                } else {
                   // Fallback: Pastel Circle
                   final category = albumData['category'] as String? ?? '';
                   Color baseColor = _softPeach;
                   if (category.contains('Trips')) baseColor = _softPeach;
                   if (category.contains('Events')) baseColor = _softPink;
                   if (category.contains('Outings')) baseColor = _lavender.withOpacity(0.5);

                   backgroundWidget = Container(
                     decoration: BoxDecoration(
                       color: baseColor,
                       shape: BoxShape.circle,
                     ),
                   );
                }
              } else if (isSelected) {
                 // SELECTION: Soft Glow
                 backgroundWidget = Container(
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: _lavender,
                     boxShadow: [
                       BoxShadow(
                         color: _lavender.withOpacity(0.4),
                         blurRadius: 12,
                         offset: const Offset(0, 4),
                       )
                     ],
                   ),
                 );
                 textColor = Colors.white;
              } else if (isToday) {
                 // TODAY: Subtle Ring
                 backgroundWidget = Container(
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     border: Border.all(color: _softPink, width: 1.5),
                   ),
                 );
                 textColor = _textPrimary;
              }
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                transform: isSelected ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (backgroundWidget != null)
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: AspectRatio(aspectRatio: 1, child: backgroundWidget),
                      ),
                    
                    Text(
                      '${day.day}',
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
          
                    // Tiny Heart for Multiple Albums (Outline style)
                    if (albumData != null && (albumData['count'] as int) > 1)
                       Positioned(
                         bottom: 6,
                         child: Icon(Icons.favorite_border_rounded, size: 10, color: _textSecondary.withOpacity(0.6)),
                       )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}
