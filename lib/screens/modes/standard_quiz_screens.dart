import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/general_question_model.dart';
import '../../models/history_quiz_models.dart';
import '../../services/general_question_data_service.dart';
import '../../services/sound_service.dart';
import '../../services/stats_service.dart';

class SurvivalModeScreen extends StatelessWidget {
  const SurvivalModeScreen({super.key});

  static const String routeName = '/survival';

  @override
  Widget build(BuildContext context) => const _StandardQuizScreen(survival: true);
}

class CasualModeScreen extends StatelessWidget {
  const CasualModeScreen({super.key});

  static const String routeName = '/casual';

  @override
  Widget build(BuildContext context) => const _CasualLevelSelect();
}

class _CasualLevelSelect extends StatelessWidget {
  const _CasualLevelSelect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Casual Mode')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) => InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _StandardQuizScreen(casualLevel: index + 1),
            ),
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.menu_book_rounded,
                      color: Theme.of(context).colorScheme.secondary),
                  const Spacer(),
                  Text('LEVEL ${index + 1}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  const Text('10 questions'),
                  const SizedBox(height: 8),
                  const Text('☆☆☆', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StandardQuizScreen extends StatefulWidget {
  const _StandardQuizScreen({this.survival = false, this.casualLevel});

  final bool survival;
  final int? casualLevel;

  @override
  State<_StandardQuizScreen> createState() => _StandardQuizScreenState();
}

class _StandardQuizScreenState extends State<_StandardQuizScreen> {
  static const int _questionSeconds = 15;

  final Random _random = Random();
  List<GeneralQuestion> _questions = <GeneralQuestion>[];
  int _index = 0;
  int _score = 0;
  int _correctCount = 0;
  int _lives = 3;
  int _streak = 0;
  int _bestStreak = 0;
  int _secondsLeft = _questionSeconds;
  Timer? _questionTimer;
  bool _loading = true;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final List<GeneralQuestion> pool = await const GeneralQuestionDataService().load();
    if (widget.survival) {
      const int targetCount = 30;
      final List<GeneralQuestion> selected = <GeneralQuestion>[];
      for (final String difficulty in <String>['easy', 'medium', 'hard']) {
        final List<GeneralQuestion> tier = pool
            .where((GeneralQuestion question) => question.difficulty == difficulty)
            .toList()..shuffle(_random);
        selected.addAll(tier.take(10));
      }
      // Backfill from the rest of the pool when a difficulty tier is missing
      // or underpopulated in the data, so survival still uses the full bank.
      if (selected.length < targetCount) {
        final Set<String> usedIds = selected.map((GeneralQuestion q) => q.id).toSet();
        final List<GeneralQuestion> remaining = pool
            .where((GeneralQuestion question) => !usedIds.contains(question.id))
            .toList()..shuffle(_random);
        selected.addAll(remaining.take(targetCount - selected.length));
      }
      _questions = selected..shuffle(_random);
    } else {
      final int start = (widget.casualLevel! - 1) * 10;
      _questions = pool.skip(start).take(10).toList(growable: false);
    }
    if (mounted) setState(() => _loading = false);
    _startQuestionTimer();
  }

  // Survival mode only: auto-fail the question when time runs out.
  void _startQuestionTimer() {
    _questionTimer?.cancel();
    if (!widget.survival) return;
    setState(() => _secondsLeft = _questionSeconds);
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        _handleTimeout();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _handleTimeout() {
    if (_answered) return;
    HapticFeedback.heavyImpact();
    unawaited(SoundService.instance.play(SoundEffect.incorrectAnswer));
    setState(() {
      _answered = true;
      _streak = 0;
      _lives--;
    });
  }

  void _answer(QuestionChoice choice) {
    if (_answered) return;
    _questionTimer?.cancel();
    final bool correct = choice.id == _questions[_index].correctChoiceId;
    correct ? HapticFeedback.mediumImpact() : HapticFeedback.heavyImpact();
    unawaited(SoundService.instance.play(
      correct ? SoundEffect.correctAnswer : SoundEffect.incorrectAnswer,
    ));
    setState(() {
      _answered = true;
      if (correct) {
        _correctCount++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _score += 1 + (_streak ~/ 5);
      } else {
        _streak = 0;
        if (widget.survival) _lives--;
      }
    });
  }

  void _next() {
    if (_lives == 0 || _index == _questions.length - 1) {
      unawaited(StatsService.instance.recordStandardQuiz(
        survival: widget.survival,
        correct: _correctCount,
        total: _questions.length,
        bestStreak: _bestStreak,
      ));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => _ModeResultScreen(
            survival: widget.survival,
            score: _score,
            total: _questions.length,
            casualLevel: widget.casualLevel,
          ),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _answered = false;
    });
    _startQuestionTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final GeneralQuestion question = _questions[_index];
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.survival ? 'Survival Run' : 'Casual Level ${widget.casualLevel}')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: _answered
            ? ElevatedButton.icon(
                onPressed: _next,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(_lives == 0 ? 'END RUN' : 'NEXT QUESTION'),
              )
            : const SizedBox.shrink(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.survival ? const Color(0xFF333333) : scheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('${_index + 1} / ${_questions.length}', style: TextStyle(color: widget.survival ? Colors.white : scheme.primary, fontWeight: FontWeight.w700)),
                  if (widget.survival) Text('LIVES $_lives  STREAK $_streak  ⏱ $_secondsLeft s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)) else Text('RELAXED PLAY', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            if (widget.survival) ...<Widget>[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _secondsLeft / _questionSeconds,
                  minHeight: 6,
                  backgroundColor: scheme.outlineVariant,
                  color: _secondsLeft <= 5 ? Colors.redAccent : scheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(question.prompt, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            for (final QuestionChoice choice in question.choices) ...<Widget>[
              OutlinedButton(
                onPressed: _answered ? null : () => _answer(choice),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(choice.text)),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModeResultScreen extends StatelessWidget {
  const _ModeResultScreen({required this.survival, required this.score, required this.total, this.casualLevel});
  final bool survival;
  final int score;
  final int total;
  final int? casualLevel;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Results')),
    body: Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Icon(survival ? Icons.shield_rounded : Icons.star_rounded, size: 56, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 16),
      Text('$score / $total', style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 8),
      Text(survival ? 'Survival score' : 'Casual Level $casualLevel complete'),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false), child: const Text('HOME')),
    ]))),
  );
}