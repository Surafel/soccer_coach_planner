import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soccer_coach_planner/models/player.dart';
import 'package:soccer_coach_planner/models/roster.dart';
import 'package:soccer_coach_planner/services/data_store.dart';
import 'package:soccer_coach_planner/services/drill_repository.dart';
import 'package:soccer_coach_planner/services/player_repository.dart';
import 'package:soccer_coach_planner/services/roster_repository.dart';
import 'package:soccer_coach_planner/services/schedule_repository.dart';
import 'package:soccer_coach_planner/services/shared_data_import.dart';

/// An in-memory shared database that, like Firestore, sends every watcher
/// the collection's full contents after each write — including the writer.
class FakeRemote implements RemoteCollections {
  final data = <String, Items>{};
  final _controllers = <String, StreamController<Items>>{};
  final writes = <String, List<Map<String, Map<String, dynamic>?>>>{};

  Items _snapshot(String c) => {
        for (final e in (data[c] ?? {}).entries) e.key: Map.of(e.value),
      };

  @override
  Stream<Items> watch(String collection) {
    final controller = _controllers.putIfAbsent(collection, StreamController<Items>.broadcast);
    return Stream.multi((listener) {
      listener.add(_snapshot(collection));
      final sub = controller.stream.listen(listener.add);
      listener.onCancel = sub.cancel;
    });
  }

  @override
  Future<void> write(String collection, Map<String, Map<String, dynamic>?> changes) async {
    (writes[collection] ??= []).add(changes);
    final items = data[collection] ??= {};
    changes.forEach((id, json) => json == null ? items.remove(id) : items[id] = json);
    _controllers[collection]?.add(_snapshot(collection));
  }
}

Player _player(String id, String name, {String rosterId = 'r1'}) =>
    Player(id: id, name: name, age: 10, rosterId: rosterId);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SyncedDataStore', () {
    test('saving writes only the items that changed', () async {
      final remote = FakeRemote();
      final rosters = RosterRepository(store: SyncedDataStore(remote));
      await rosters.load();

      await rosters.saveRoster(const Roster(id: 'a', name: 'Blue'));
      await rosters.saveRoster(const Roster(id: 'b', name: 'Red'));
      await rosters.saveRoster(const Roster(id: 'a', name: 'Blue Team'));
      await rosters.deleteRoster('b');

      expect(remote.writes['rosters']!.map((w) => w.keys.toList()), [
        ['a'],
        ['b'],
        ['a'],
        ['b'],
      ]);
      expect(remote.writes['rosters']!.last['b'], isNull, reason: 'deleted');
      expect(remote.data['rosters']!.keys, ['a']);
    });

    test('a change on one device shows up on another', () async {
      final remote = FakeRemote();
      final storeA = SyncedDataStore(remote);
      final storeB = SyncedDataStore(remote);
      final deviceA = RosterRepository(store: storeA);
      final deviceB = RosterRepository(store: storeB);
      await deviceA.load();
      await deviceB.load();
      var notified = 0;
      storeB.addListener(() => notified++);

      await deviceA.saveRoster(const Roster(id: 'a', name: 'Blue'));
      await pumpEventQueue();

      expect(deviceB.rosters.map((r) => r.name), ['Blue']);
      expect(notified, 1);
    });

    test('a device isn\'t notified about its own writes', () async {
      final store = SyncedDataStore(FakeRemote());
      final rosters = RosterRepository(store: store);
      await rosters.load();
      var notified = 0;
      store.addListener(() => notified++);

      await rosters.saveRoster(const Roster(id: 'a', name: 'Blue'));
      await pumpEventQueue();

      expect(notified, 0);
    });

    test('coaches editing different items don\'t overwrite each other', () async {
      final remote = FakeRemote();
      final deviceA = PlayerRepository(store: SyncedDataStore(remote));
      final deviceB = PlayerRepository(store: SyncedDataStore(remote));
      await deviceA.load();
      await deviceB.load();

      await deviceA.savePlayer(_player('p1', 'Sam'));
      await deviceB.savePlayer(_player('p2', 'Alex'));
      await pumpEventQueue();

      expect(remote.data['players']!.keys.toSet(), {'p1', 'p2'});
      expect(deviceA.players.map((p) => p.name), ['Sam', 'Alex']);
      expect(deviceB.players.map((p) => p.name), ['Sam', 'Alex']);
    });

    test('scheduling different dates for the same group doesn\'t conflict', () async {
      final remote = FakeRemote();
      final deviceA = ScheduleRepository(store: SyncedDataStore(remote));
      final deviceB = ScheduleRepository(store: SyncedDataStore(remote));
      await deviceA.load();
      await deviceB.load();

      await deviceA.assignSession('r1', '2026-01-03', 's1');
      await deviceB.assignSession('r1', '2026-01-10', 's2');
      await pumpEventQueue();

      for (final device in [deviceA, deviceB]) {
        expect(device.scheduleFor('r1').assignments, {
          '2026-01-03': 's1',
          '2026-01-10': 's2',
        });
      }
    });

    test('items keep the order they were added in', () async {
      final remote = FakeRemote();
      final deviceA = RosterRepository(store: SyncedDataStore(remote));
      await deviceA.load();
      // Ids that would sort differently from the order they're added.
      await deviceA.saveRoster(const Roster(id: 'z', name: 'First'));
      await deviceA.saveRoster(const Roster(id: 'a', name: 'Second'));
      await deviceA.saveRoster(const Roster(id: 'm', name: 'Third'));

      final deviceB = RosterRepository(store: SyncedDataStore(remote));
      await deviceB.load();
      expect(deviceB.rosters.map((r) => r.name), ['First', 'Second', 'Third']);
    });

    test('the starter drills are added once to an empty club', () async {
      final remote = FakeRemote();
      final deviceA = DrillRepository(store: SyncedDataStore(remote));
      await deviceA.load();
      final count = deviceA.drills.length;
      expect(count, greaterThan(0));

      final deviceB = DrillRepository(store: SyncedDataStore(remote));
      await deviceB.load();
      expect(deviceB.drills.length, count);
      expect(remote.writes['drills'], hasLength(1), reason: 'device B didn\'t re-seed');
    });
  });

  group('LocalDataStore', () {
    test('keeps data across app restarts', () async {
      final first = RosterRepository();
      await first.load();
      await first.saveRoster(const Roster(id: 'a', name: 'Blue'));

      final second = RosterRepository();
      await second.load();
      expect(second.rosters.map((r) => r.name), ['Blue']);
    });
  });

  group('copying this device\'s data to the club', () {
    test('copies everything, including data saved by earlier versions', () async {
      SharedPreferences.setMockInitialValues({
        // Saved by a version from before the shared-data change.
        'rosters_v1': '[{"id":"r1","name":"Blue","coachIds":[]}]',
      });
      final device = LocalDataStore();
      final players = PlayerRepository(store: device);
      await players.load();
      await players.savePlayer(_player('p1', 'Sam'));
      expect(await deviceHasOwnData(), isTrue);

      final remote = FakeRemote();
      await copyDeviceDataTo(SyncedDataStore(remote));

      final rosters = RosterRepository(store: SyncedDataStore(remote));
      final sharedPlayers = PlayerRepository(store: SyncedDataStore(remote));
      final drills = DrillRepository(store: SyncedDataStore(remote));
      await Future.wait([rosters.load(), sharedPlayers.load(), drills.load()]);
      expect(rosters.rosters.map((r) => r.name), ['Blue']);
      expect(sharedPlayers.players.map((p) => p.name), ['Sam']);
      expect(drills.drills, isNotEmpty);
    });

    test('a device with only the starter drills has nothing of its own', () async {
      await DrillRepository().load();
      expect(await deviceHasOwnData(), isFalse);
    });
  });
}
