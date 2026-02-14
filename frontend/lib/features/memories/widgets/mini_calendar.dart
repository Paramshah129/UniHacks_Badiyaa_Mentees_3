
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class MiniCalendar extends StatefulWidget {
  final VoidCallback onTap;

  const MiniCalendar({super.key, required this.onTap});

  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  // Pastel Palette
  final Color _lavender = const Color(0xFFC9B6FF);
  final Color _textPrimary = const Color(0xFF2E2E3A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daily Engagement 💕",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _lavender),
              ],
            ),
            const SizedBox(height: 12),
            IgnorePointer( // Interactive only via main container tap
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 30)),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.week, // Condensed view
                headerVisible: false,
                daysOfWeekVisible: false,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: _lavender,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  defaultTextStyle: GoogleFonts.poppins(color: _textPrimary),
                  weekendTextStyle: GoogleFonts.poppins(color: _textPrimary),
                ),
                availableGestures: AvailableGestures.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
