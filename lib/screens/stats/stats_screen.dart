import 'package:flutter/material.dart';

import '../../services/stats_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const String routeName = '/stats';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Stats')),
      body: FutureBuilder<QuizStats>(
        future: StatsService.instance.load(),
        builder: (BuildContext context, AsyncSnapshot<QuizStats> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final QuizStats stats = snapshot.data!;
          final ColorScheme scheme = Theme.of(context).colorScheme;
          final List<_StatRow> rows = <_StatRow>[
            _StatRow(Icons.menu_book_rounded, 'Casual quizzes played', '${stats.casualQuizzesPlayed}'),
            _StatRow(Icons.shield_rounded, 'Survival runs played', '${stats.survivalRunsPlayed}'),
            _StatRow(Icons.emoji_events_rounded, 'Best survival score', '${stats.bestSurvivalScore}'),
            _StatRow(Icons.local_fire_department_rounded, 'Best survival streak', '${stats.bestSurvivalStreak}'),
            _StatRow(Icons.question_answer_rounded, 'Questions answered', '${stats.totalQuestionsAnswered}'),
            _StatRow(Icons.check_circle_rounded, 'Correct answers', '${stats.totalCorrectAnswers}'),
            _StatRow(Icons.percent_rounded, 'Overall accuracy', '${(stats.accuracy * 100).round()}%'),
            _StatRow(Icons.auto_stories_rounded, 'History chapters completed', '${stats.historyChaptersCompleted}'),
            _StatRow(Icons.flag_rounded, 'History quiz completions', '${stats.historyQuizzesCompleted}'),
          ];
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final _StatRow row = rows[index];
              return Card(
                child: ListTile(
                  leading: Icon(row.icon, color: scheme.primary),
                  title: Text(row.label),
                  trailing: Text(
                    row.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatRow {
  const _StatRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}
