import 'roster.dart';

/// Which of a roster's players were present for practice on a given date.
class AttendanceRecord {
  final String rosterId;
  final String date; // ISO yyyy-MM-dd
  final List<String> presentPlayerIds;

  const AttendanceRecord({
    required this.rosterId,
    required this.date,
    required this.presentPlayerIds,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        // Records saved before rosters existed belong to the legacy roster
        // created for them on upgrade, so existing data isn't lost.
        rosterId: json['rosterId'] as String? ?? legacyRosterId,
        date: json['date'] as String,
        presentPlayerIds: (json['presentPlayerIds'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'rosterId': rosterId,
        'date': date,
        'presentPlayerIds': presentPlayerIds,
      };

  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
