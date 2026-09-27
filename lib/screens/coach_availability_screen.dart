import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/coach.dart';
import '../services/coach_availability_repository.dart';
import '../widgets/schedule_entry_tile.dart';

/// Lets a coach (or whoever runs the device) mark availability for
/// upcoming practice dates, so it's easy to see who's free when assigning
/// coaches to a session.
class CoachAvailabilityScreen extends StatefulWidget {
  final Coach coach;
  final CoachAvailabilityRepository availabilityRepository;

  const CoachAvailabilityScreen({
    super.key,
    required this.coach,
    required this.availabilityRepository,
  });

  @override
  State<CoachAvailabilityScreen> createState() => _CoachAvailabilityScreenState();
}

class _CoachAvailabilityScreenState extends State<CoachAvailabilityScreen> {
  final Set<String> _extraDates = {};

  List<DateTime> _upcomingSaturdays(int count) {
    var day = DateTime.now();
    while (day.weekday != DateTime.saturday) {
      day = day.add(const Duration(days: 1));
    }
    return [for (var i = 0; i < count; i++) day.add(Duration(days: 7 * i))];
  }

  List<String> _dates() {
    final answered = widget.availabilityRepository.allFor(widget.coach.id).keys;
    final dates = <String>{
      for (final day in _upcomingSaturdays(10)) AttendanceRecord.isoDate(day),
      ...answered,
      ..._extraDates,
    }.toList()
      ..sort();
    return dates;
  }

  Future<void> _setAvailability(String date, bool? available) async {
    final current = widget.availabilityRepository.availabilityFor(widget.coach.id, date);
    await widget.availabilityRepository.setAvailability(
      widget.coach.id,
      date,
      current == available ? null : available,
    );
    setState(() {});
  }

  Future<void> _addDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() => _extraDates.add(AttendanceRecord.isoDate(picked)));
  }

  @override
  Widget build(BuildContext context) {
    final dates = _dates();
    return Scaffold(
      appBar: AppBar(title: Text('${widget.coach.name} — Availability')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final date in dates)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(formatScheduleDate(date))),
                    ChoiceChip(
                      label: const Text('Available'),
                      selected: widget.availabilityRepository
                              .availabilityFor(widget.coach.id, date) ==
                          true,
                      onSelected: (_) => _setAvailability(date, true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Can't make it"),
                      selected: widget.availabilityRepository
                              .availabilityFor(widget.coach.id, date) ==
                          false,
                      onSelected: (_) => _setAvailability(date, false),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDate,
        icon: const Icon(Icons.calendar_month),
        label: const Text('Add date'),
      ),
    );
  }
}
