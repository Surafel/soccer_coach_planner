/// Whether a coach said they can make it to practice on a given date.
class CoachAvailability {
  final String coachId;
  final String date; // ISO yyyy-MM-dd
  final bool available;

  const CoachAvailability({
    required this.coachId,
    required this.date,
    required this.available,
  });

  factory CoachAvailability.fromJson(Map<String, dynamic> json) => CoachAvailability(
        coachId: json['coachId'] as String,
        date: json['date'] as String,
        available: json['available'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'coachId': coachId,
        'date': date,
        'available': available,
      };
}
