import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/season_progress.dart';

const _progressKey = 'season_progress_v1';

class SeasonProgressRepository {
  Map<String, SeasonProgress> _progressByRoster = {};
  SharedPreferences? _prefs;

  SeasonProgress? forRoster(String rosterId) => _progressByRoster[rosterId];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_progressKey);
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _progressByRoster = data.map(
      (rosterId, json) =>
          MapEntry(rosterId, SeasonProgress.fromJson(json as Map<String, dynamic>)),
    );
  }

  Future<void> save(SeasonProgress progress) async {
    _progressByRoster = {..._progressByRoster, progress.rosterId: progress};
    await _persist();
  }

  Future<void> deleteForRoster(String rosterId) async {
    _progressByRoster = {..._progressByRoster}..remove(rosterId);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _progressKey,
      jsonEncode(_progressByRoster.map((rosterId, p) => MapEntry(rosterId, p.toJson()))),
    );
  }
}
