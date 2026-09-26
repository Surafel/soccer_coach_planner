enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

/// Maps each day of the week to an optional saved Session id.
/// A null value means "no practice" (rest day).
class WeeklySchedule {
  final Map<DayOfWeek, String?> assignments;

  const WeeklySchedule(this.assignments);

  factory WeeklySchedule.empty() =>
      WeeklySchedule({for (final d in DayOfWeek.values) d: null});

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) => WeeklySchedule({
        for (final d in DayOfWeek.values) d: json[d.name] as String?,
      });

  Map<String, dynamic> toJson() => {
        for (final entry in assignments.entries) entry.key.name: entry.value,
      };

  WeeklySchedule copyWithAssignment(DayOfWeek day, String? sessionId) =>
      WeeklySchedule({...assignments, day: sessionId});

  String? sessionIdFor(DayOfWeek day) => assignments[day];
}
