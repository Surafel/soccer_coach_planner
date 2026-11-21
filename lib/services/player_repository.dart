import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';
import 'data_store.dart';
import 'stored_repository.dart';

class PlayerRepository extends StoredRepository {
  PlayerRepository({DataStore? store}) : super('players', store);

  List<Player> _players = [];

  List<Player> get players => List.unmodifiable(_players);

  List<Player> playersForRoster(String rosterId) =>
      _players.where((p) => p.rosterId == rosterId).toList();

  @override
  List<StoredItem> toItems() => [for (final p in _players) StoredItem(p.id, p.toJson())];

  @override
  void fromItems(List<StoredItem> items) =>
      _players = [for (final e in items) Player.fromJson(e.value)];

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'roster_v1') as List?;
    return data
        ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
        .map((p) => StoredItem(p.id, p.toJson()))
        .toList();
  }

  Player? byId(String id) {
    for (final p in _players) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> savePlayer(Player player) async {
    final index = _players.indexWhere((p) => p.id == player.id);
    if (index >= 0) {
      _players[index] = player;
    } else {
      _players.add(player);
    }
    await persist();
  }

  Future<void> deletePlayer(String id) async {
    _players.removeWhere((p) => p.id == id);
    await persist();
  }

  Future<void> deleteForRoster(String rosterId) async {
    _players.removeWhere((p) => p.rosterId == rosterId);
    await persist();
  }
}
