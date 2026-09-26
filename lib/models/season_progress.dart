/// Tracks one roster's progress through its built-in season curriculum, so
/// the app can automatically assign the next week's session every Saturday
/// while still noticing (and pausing on) a coach's manual override.
class SeasonProgress {
  final String rosterId;
  final int currentWeek;

  /// The session id the system itself last put on Saturday for
  /// [currentWeek]. If Saturday no longer holds this session the next time
  /// we check, a coach must have overridden it — so progress pauses on the
  /// same week instead of advancing.
  final String lastAssignedSessionId;

  /// ISO yyyy-MM-dd of the Saturday [lastAssignedSessionId] was assigned
  /// for, so we only run the auto-assignment once per Saturday.
  final String lastAssignedDate;

  const SeasonProgress({
    required this.rosterId,
    required this.currentWeek,
    required this.lastAssignedSessionId,
    required this.lastAssignedDate,
  });

  factory SeasonProgress.fromJson(Map<String, dynamic> json) => SeasonProgress(
        rosterId: json['rosterId'] as String,
        currentWeek: json['currentWeek'] as int,
        lastAssignedSessionId: json['lastAssignedSessionId'] as String,
        lastAssignedDate: json['lastAssignedDate'] as String,
      );

  Map<String, dynamic> toJson() => {
        'rosterId': rosterId,
        'currentWeek': currentWeek,
        'lastAssignedSessionId': lastAssignedSessionId,
        'lastAssignedDate': lastAssignedDate,
      };
}
