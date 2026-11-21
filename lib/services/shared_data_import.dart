import 'attendance_repository.dart';
import 'coach_assignment_repository.dart';
import 'coach_availability_repository.dart';
import 'coach_repository.dart';
import 'data_store.dart';
import 'drill_repository.dart';
import 'player_repository.dart';
import 'roster_repository.dart';
import 'schedule_repository.dart';
import 'season_progress_repository.dart';
import 'session_repository.dart';
import 'stored_repository.dart';

/// Every repository, each reading this device's own storage.
List<StoredRepository> _deviceRepositories(DataStore store) => [
      DrillRepository(store: store),
      SessionRepository(store: store),
      ScheduleRepository(store: store),
      RosterRepository(store: store),
      PlayerRepository(store: store),
      CoachRepository(store: store),
      CoachAvailabilityRepository(store: store),
      CoachAssignmentRepository(store: store),
      AttendanceRepository(store: store),
      SeasonProgressRepository(store: store),
    ];

/// The names of every collection the app stores.
List<String> get allCollections =>
    [for (final r in _deviceRepositories(LocalDataStore())) r.collection];

/// Whether this device has data a coach created — groups, players, coaches
/// or sessions — as opposed to just the starter drills.
Future<bool> deviceHasOwnData({DataStore? device}) async {
  final store = device ?? LocalDataStore();
  final rosters = RosterRepository(store: store);
  final players = PlayerRepository(store: store);
  final coaches = CoachRepository(store: store);
  final sessions = SessionRepository(store: store);
  await Future.wait([rosters.load(), players.load(), coaches.load(), sessions.load()]);
  return rosters.rosters.isNotEmpty ||
      players.players.isNotEmpty ||
      coaches.coaches.isNotEmpty ||
      sessions.sessions.isNotEmpty;
}

/// Copies everything stored on this device into [shared], replacing what's
/// there. Meant for the first coach to sign in, while the club has no data.
Future<void> copyDeviceDataTo(DataStore shared, {DataStore? device}) async {
  final store = device ?? LocalDataStore();
  // Loading moves any data saved by earlier versions into the current format.
  for (final repository in _deviceRepositories(store)) {
    await repository.load();
  }
  for (final collection in allCollections) {
    final items = await store.load(collection);
    if (items == null) continue;
    await shared.load(collection);
    await shared.saveAll(collection, items);
  }
}
