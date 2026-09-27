/// Which of a roster's coaches are actually assigned to run practice on a
/// given date, distinct from the roster's season-long coach list.
class CoachAssignment {
  final String rosterId;
  final String date; // ISO yyyy-MM-dd
  final List<String> coachIds;

  const CoachAssignment({
    required this.rosterId,
    required this.date,
    required this.coachIds,
  });

  factory CoachAssignment.fromJson(Map<String, dynamic> json) => CoachAssignment(
        rosterId: json['rosterId'] as String,
        date: json['date'] as String,
        coachIds: (json['coachIds'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'rosterId': rosterId,
        'date': date,
        'coachIds': coachIds,
      };
}
