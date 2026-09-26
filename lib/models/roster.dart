import 'age_group.dart';

/// Id given to the single implicit roster that existing players/schedule/
/// attendance data belonged to before multiple rosters existed, so
/// upgrading the app never loses a coach's existing data.
const legacyRosterId = 'legacy-roster';

/// A team: a named group of players with its own coaches, its own weekly
/// schedule, and (if an age group is set) its own automatically-progressing
/// season plan.
class Roster {
  final String id;
  final String name;
  final AgeGroup? ageGroup;
  final List<String> coachNames;

  const Roster({
    required this.id,
    required this.name,
    this.ageGroup,
    this.coachNames = const [],
  });

  factory Roster.fromJson(Map<String, dynamic> json) => Roster(
        id: json['id'] as String,
        name: json['name'] as String,
        ageGroup: (json['ageGroup'] as String?) == null
            ? null
            : AgeGroup.values.byName(json['ageGroup'] as String),
        coachNames: (json['coachNames'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (ageGroup != null) 'ageGroup': ageGroup!.name,
        'coachNames': coachNames,
      };

  Roster copyWith({
    String? name,
    AgeGroup? ageGroup,
    bool clearAgeGroup = false,
    List<String>? coachNames,
  }) =>
      Roster(
        id: id,
        name: name ?? this.name,
        ageGroup: clearAgeGroup ? null : ageGroup ?? this.ageGroup,
        coachNames: coachNames ?? this.coachNames,
      );
}
