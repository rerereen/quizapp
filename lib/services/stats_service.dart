import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight play stats (no achievements/badges), backed by SharedPreferences.
class QuizStats {
  const QuizStats({
    required this.casualQuizzesPlayed,
    required this.survivalRunsPlayed,
    required this.totalQuestionsAnswered,
    required this.totalCorrectAnswers,
    required this.bestSurvivalScore,
    required this.bestSurvivalStreak,
    required this.historyChaptersCompleted,
    required this.historyQuizzesCompleted,
  });

  static const QuizStats empty = QuizStats(
    casualQuizzesPlayed: 0,
    survivalRunsPlayed: 0,
    totalQuestionsAnswered: 0,
    totalCorrectAnswers: 0,
    bestSurvivalScore: 0,
    bestSurvivalStreak: 0,
    historyChaptersCompleted: 0,
    historyQuizzesCompleted: 0,
  );

  final int casualQuizzesPlayed;
  final int survivalRunsPlayed;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final int bestSurvivalScore;
  final int bestSurvivalStreak;
  final int historyChaptersCompleted;
  final int historyQuizzesCompleted;

  double get accuracy =>
      totalQuestionsAnswered == 0 ? 0 : totalCorrectAnswers / totalQuestionsAnswered;
}

class StatsService {
  StatsService._();

  static final StatsService instance = StatsService._();

  static const String _kCasualPlayed = 'stats_casualQuizzesPlayed';
  static const String _kSurvivalPlayed = 'stats_survivalRunsPlayed';
  static const String _kQuestionsAnswered = 'stats_totalQuestionsAnswered';
  static const String _kCorrectAnswers = 'stats_totalCorrectAnswers';
  static const String _kBestSurvivalScore = 'stats_bestSurvivalScore';
  static const String _kBestSurvivalStreak = 'stats_bestSurvivalStreak';
  static const String _kHistoryChapters = 'stats_historyChaptersCompleted';
  static const String _kHistoryQuizzes = 'stats_historyQuizzesCompleted';

  Future<QuizStats> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return QuizStats(
      casualQuizzesPlayed: prefs.getInt(_kCasualPlayed) ?? 0,
      survivalRunsPlayed: prefs.getInt(_kSurvivalPlayed) ?? 0,
      totalQuestionsAnswered: prefs.getInt(_kQuestionsAnswered) ?? 0,
      totalCorrectAnswers: prefs.getInt(_kCorrectAnswers) ?? 0,
      bestSurvivalScore: prefs.getInt(_kBestSurvivalScore) ?? 0,
      bestSurvivalStreak: prefs.getInt(_kBestSurvivalStreak) ?? 0,
      historyChaptersCompleted: prefs.getInt(_kHistoryChapters) ?? 0,
      historyQuizzesCompleted: prefs.getInt(_kHistoryQuizzes) ?? 0,
    );
  }

  Future<void> recordStandardQuiz({
    required bool survival,
    required int correct,
    required int total,
    required int bestStreak,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kQuestionsAnswered, (prefs.getInt(_kQuestionsAnswered) ?? 0) + total);
    await prefs.setInt(_kCorrectAnswers, (prefs.getInt(_kCorrectAnswers) ?? 0) + correct);
    if (survival) {
      await prefs.setInt(_kSurvivalPlayed, (prefs.getInt(_kSurvivalPlayed) ?? 0) + 1);
      if (correct > (prefs.getInt(_kBestSurvivalScore) ?? 0)) {
        await prefs.setInt(_kBestSurvivalScore, correct);
      }
      if (bestStreak > (prefs.getInt(_kBestSurvivalStreak) ?? 0)) {
        await prefs.setInt(_kBestSurvivalStreak, bestStreak);
      }
    } else {
      await prefs.setInt(_kCasualPlayed, (prefs.getInt(_kCasualPlayed) ?? 0) + 1);
    }
  }

  Future<void> recordHistoryChapterComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHistoryChapters, (prefs.getInt(_kHistoryChapters) ?? 0) + 1);
  }

  Future<void> recordHistoryQuizComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHistoryQuizzes, (prefs.getInt(_kHistoryQuizzes) ?? 0) + 1);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (final String key in <String>[
      _kCasualPlayed,
      _kSurvivalPlayed,
      _kQuestionsAnswered,
      _kCorrectAnswers,
      _kBestSurvivalScore,
      _kBestSurvivalStreak,
      _kHistoryChapters,
      _kHistoryQuizzes,
    ]) {
      await prefs.remove(key);
    }
  }
}
