import 'package:shared_preferences/shared_preferences.dart';

import '../models/season_progress.dart';
import 'data_store.dart';
import 'stored_repository.dart';

class SeasonProgressRepository extends StoredRepository {
  SeasonProgressRepository({DataStore? store}) : super('seasonProgress', store);

  Map<String, SeasonProgress> _progressByRoster = {};

  SeasonProgress? forRoster(String rosterId) => _progressByRoster[rosterId];

  @override
  List<StoredItem> toItems() => [
        for (final p in _progressByRoster.values) StoredItem(p.rosterId, p.toJson()),
      ];

  @override
  void fromItems(List<StoredItem> items) => _progressByRoster = {
        for (final e in items) e.key: SeasonProgress.fromJson(e.value),
      };

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'season_progress_v1') as Map<String, dynamic>?;
    return data?.values
        .map((json) => SeasonProgress.fromJson(json as Map<String, dynamic>))
        .map((p) => StoredItem(p.rosterId, p.toJson()))
        .toList();
  }

  Future<void> save(SeasonProgress progress) async {
    _progressByRoster = {..._progressByRoster, progress.rosterId: progress};
    await persist();
  }

  Future<void> deleteForRoster(String rosterId) async {
    _progressByRoster = {..._progressByRoster}..remove(rosterId);
    await persist();
  }
}
