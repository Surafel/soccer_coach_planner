import 'package:flutter/material.dart';

import '../services/attendance_repository.dart';
import '../services/roster_repository.dart';

class AttendanceScreen extends StatefulWidget {
  final String date;
  final RosterRepository rosterRepository;
  final AttendanceRepository attendanceRepository;

  const AttendanceScreen({
    super.key,
    required this.date,
    required this.rosterRepository,
    required this.attendanceRepository,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Set<String> _present;

  @override
  void initState() {
    super.initState();
    final existing = widget.attendanceRepository.forDate(widget.date);
    _present = {...?existing?.presentPlayerIds};
  }

  Future<void> _save() async {
    await widget.attendanceRepository.saveAttendance(widget.date, _present.toList());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.rosterRepository.players;
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance · ${widget.date}'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_present.length} / ${players.length} present',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          Expanded(
            child: players.isEmpty
                ? const Center(
                    child: Text(
                      'No players yet. Add your roster in the Roster tab.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      final isPresent = _present.contains(player.id);
                      return CheckboxListTile(
                        value: isPresent,
                        title: Text(player.name),
                        secondary: CircleAvatar(
                          child: Text(
                            player.jerseyNumber?.toString() ??
                                (player.name.isNotEmpty
                                    ? player.name[0].toUpperCase()
                                    : '?'),
                          ),
                        ),
                        onChanged: (checked) => setState(() {
                          if (checked == true) {
                            _present.add(player.id);
                          } else {
                            _present.remove(player.id);
                          }
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
