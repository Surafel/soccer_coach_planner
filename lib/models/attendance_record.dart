/// Which roster players were present for practice on a given date.
class AttendanceRecord {
  final String date; // ISO yyyy-MM-dd
  final List<String> presentPlayerIds;

  const AttendanceRecord({
    required this.date,
    required this.presentPlayerIds,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        date: json['date'] as String,
        presentPlayerIds: (json['presentPlayerIds'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'presentPlayerIds': presentPlayerIds,
      };

  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
