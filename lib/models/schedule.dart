/// Maps specific calendar dates (ISO yyyy-MM-dd) to an assigned Session id.
/// Unlike a recurring weekly template, only dates a coach has actually put
/// on the calendar appear here — there's no implicit repetition.
class Schedule {
  final Map<String, String> assignments; // isoDate -> sessionId

  const Schedule(this.assignments);

  factory Schedule.empty() => const Schedule({});

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        json.map((date, sessionId) => MapEntry(date, sessionId as String)),
      );

  Map<String, dynamic> toJson() => assignments;

  String? sessionIdFor(String date) => assignments[date];

  /// Returns null to clear that date off the schedule entirely.
  Schedule copyWithAssignment(String date, String? sessionId) {
    final updated = Map<String, String>.from(assignments);
    if (sessionId == null) {
      updated.remove(date);
    } else {
      updated[date] = sessionId;
    }
    return Schedule(updated);
  }

  /// Scheduled dates in chronological order.
  List<String> get sortedDates => assignments.keys.toList()..sort();
}
