import 'package:shared_preferences/shared_preferences.dart';

/// Story id used by the Villasis history quiz; matches "id" in villasis_history.json.
const String kVillasisHistoryStoryId = 'villasis_history';

/// Persists and restores chapter/question progress so players can resume
/// their last position instead of restarting the whole story.
class HistoryProgress {
  const HistoryProgress({
    required this.chapterIndex,
    required this.questionIndex,
    required this.narrationIndex,
    required this.isNarrationStage,
    required this.scores,
  });

  final int chapterIndex;
  final int questionIndex;
  final int narrationIndex;
  final bool isNarrationStage;
  final List<int> scores;

  static String _prefix(String storyId) => 'history_progress_$storyId';

  static Future<void> save(String storyId, HistoryProgress progress) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String p = _prefix(storyId);
    await prefs.setInt('${p}_chapter', progress.chapterIndex);
    await prefs.setInt('${p}_question', progress.questionIndex);
    await prefs.setInt('${p}_narration', progress.narrationIndex);
    await prefs.setBool('${p}_isNarration', progress.isNarrationStage);
    await prefs.setStringList(
      '${p}_scores',
      progress.scores.map((int s) => s.toString()).toList(growable: false),
    );
  }

  static Future<HistoryProgress?> load(String storyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String p = _prefix(storyId);
    final int? chapterIndex = prefs.getInt('${p}_chapter');
    final List<String>? scores = prefs.getStringList('${p}_scores');
    if (chapterIndex == null || scores == null) return null;
    return HistoryProgress(
      chapterIndex: chapterIndex,
      questionIndex: prefs.getInt('${p}_question') ?? 0,
      narrationIndex: prefs.getInt('${p}_narration') ?? 0,
      isNarrationStage: prefs.getBool('${p}_isNarration') ?? true,
      scores: scores.map(int.parse).toList(growable: false),
    );
  }

  static Future<void> clear(String storyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String p = _prefix(storyId);
    await prefs.remove('${p}_chapter');
    await prefs.remove('${p}_question');
    await prefs.remove('${p}_narration');
    await prefs.remove('${p}_isNarration');
    await prefs.remove('${p}_scores');
  }
}
