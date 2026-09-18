import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/history_quiz_models.dart';
import '../../services/history_progress_service.dart';
import '../../services/history_quiz_data_service.dart';
import '../../services/sound_service.dart';
import '../../services/stats_service.dart';

class VillasisHistoryScreen extends StatefulWidget {
  const VillasisHistoryScreen({
    super.key,
    this.assetPath = 'assets/data/villasis_history.json',
  });

  static const String routeName = '/villasis-history';
  final String assetPath;

  @override
  State<VillasisHistoryScreen> createState() => _VillasisHistoryScreenState();
}

class _VillasisHistoryScreenState extends State<VillasisHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  final List<int> _chapterScores = <int>[];
  VillasisHistoryData? _data;
  int _chapterIndex = 0;
  int _questionIndex = 0;
  int _narrationIndex = 0;
  int _introIndex = 0;
  bool _isIntroStage = false;
  bool _isNarrationStage = true;
  bool _showChoices = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    try {
      final VillasisHistoryData data = await const HistoryQuizDataService()
          .load(widget.assetPath);
      if (!mounted) return;
      setState(() {
        _data = data;
        _chapterScores.addAll(List<int>.filled(data.chapters.length, 0));
        _isLoading = false;
      });
      if (data.chapters.isEmpty ||
          data.chapters.any((HistoryChapter chapter) => chapter.questions.isEmpty)) {
        return;
      }
      final HistoryProgress? saved = await HistoryProgress.load(data.id);
      if (saved != null && saved.chapterIndex < data.chapters.length) {
        await _resumeFromProgress(saved);
        return;
      }
      if (data.introduction.isNotEmpty) {
        await _playIntroduction();
      } else {
        await _playChapter();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resumeFromProgress(HistoryProgress saved) async {
    final HistoryChapter chapter = _data!.chapters[saved.chapterIndex];
    final bool hasNarration = saved.isNarrationStage && chapter.narration.isNotEmpty;
    setState(() {
      _chapterIndex = saved.chapterIndex;
      _questionIndex = chapter.questions.isEmpty
          ? 0
          : saved.questionIndex.clamp(0, chapter.questions.length - 1);
      _narrationIndex = hasNarration
          ? saved.narrationIndex.clamp(0, chapter.narration.length - 1)
          : 0;
      _isNarrationStage = hasNarration;
      for (int i = 0; i < saved.scores.length && i < _chapterScores.length; i++) {
        _chapterScores[i] = saved.scores[i];
      }
    });
    await _addGuideMessage(
      'Welcome back! Continuing Chapter ${_chapterIndex + 1}: ${chapter.title}',
      isLabel: true,
    );
    if (_isNarrationStage) {
      await _addGuideMessage(chapter.narration[_narrationIndex]);
    } else {
      await _askCurrentQuestion();
    }
  }

  Future<void> _playIntroduction() async {
    setState(() {
      _isIntroStage = true;
      _introIndex = 0;
    });
    await _addGuideMessage(_data!.introduction.first);
  }

  Future<void> _showNextIntro() async {
    if (!_isIntroStage) return;
    HapticFeedback.selectionClick();
    final List<String> introduction = _data!.introduction;
    if (_introIndex + 1 < introduction.length) {
      setState(() => _introIndex++);
      await _addGuideMessage(introduction[_introIndex]);
      return;
    }
    setState(() {
      _isIntroStage = false;
      _messages.clear();
    });
    await _playChapter();
  }

  Future<void> _playChapter() async {
    final VillasisHistoryData data = _data!;
    final HistoryChapter chapter = data.chapters[_chapterIndex];
    setState(() {
      _isNarrationStage = true;
      _narrationIndex = 0;
    });
    await _saveProgress();
    await _addGuideMessage(
      'Chapter ${_chapterIndex + 1}: ${chapter.title}',
      isLabel: true,
    );
    if (chapter.narration.isEmpty) {
      setState(() => _isNarrationStage = false);
      await _askCurrentQuestion();
      return;
    }
    await _addGuideMessage(chapter.narration.first);
  }

  Future<void> _showNextNarration() async {
    if (!_isNarrationStage) {
      return;
    }
    HapticFeedback.selectionClick();
    final HistoryChapter chapter = _data!.chapters[_chapterIndex];
    if (_narrationIndex + 1 < chapter.narration.length) {
      setState(() => _narrationIndex++);
      await _saveProgress();
      await _addGuideMessage(chapter.narration[_narrationIndex]);
      return;
    }

    setState(() {
      _isNarrationStage = false;
      _messages.clear();
    });
    await _saveProgress();
    await _askCurrentQuestion();
  }

  Future<void> _askCurrentQuestion() async {
    final HistoryQuestion question = _data!.chapters[_chapterIndex]
        .questions[_questionIndex];
    await _addGuideMessage(question.prompt);
    if (mounted) setState(() => _showChoices = true);
  }

  Future<void> _addGuideMessage(String text, {bool isLabel = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(
      () => _messages.add(
        _ChatMessage(
          text: text,
          guideName: _data?.guideName ?? '',
          isLabel: isLabel,
        ),
      ),
    );
    _scrollToLatest();
  }

  Future<void> _saveProgress() async {
    if (_data == null) return;
    await HistoryProgress.save(
      _data!.id,
      HistoryProgress(
        chapterIndex: _chapterIndex,
        questionIndex: _questionIndex,
        narrationIndex: _narrationIndex,
        isNarrationStage: _isNarrationStage,
        scores: _chapterScores,
      ),
    );
  }

  Future<void> _answer(QuestionChoice choice) async {
    if (!_showChoices) return;
    final HistoryQuestion question = _data!.chapters[_chapterIndex]
        .questions[_questionIndex];
    final bool isCorrect = choice.id == question.correctChoiceId;
    isCorrect ? HapticFeedback.mediumImpact() : HapticFeedback.heavyImpact();
    unawaited(SoundService.instance.play(
      isCorrect ? SoundEffect.correctAnswer : SoundEffect.incorrectAnswer,
    ));
    setState(() {
      _showChoices = false;
      _messages.add(_ChatMessage(text: choice.text, isPlayer: true));
      if (isCorrect) _chapterScores[_chapterIndex]++;
    });
    _scrollToLatest();
    await _addGuideMessage(
      isCorrect ? question.feedbackCorrect : question.feedbackIncorrect,
    );
    if (!mounted) return;
    if (_questionIndex + 1 < _data!.chapters[_chapterIndex].questions.length) {
      setState(() => _questionIndex++);
      await _saveProgress();
      await _askCurrentQuestion();
      return;
    }
    await _celebrateChapterComplete();
    if (!mounted) return;
    if (_chapterIndex + 1 < _data!.chapters.length) {
      setState(() {
        _chapterIndex++;
        _questionIndex = 0;
        _messages.clear();
      });
      await _playChapter();
    } else {
      await HistoryProgress.clear(_data!.id);
      await StatsService.instance.recordHistoryQuizComplete();
      _showSummary();
    }
  }

  Future<void> _celebrateChapterComplete() async {
    if (!mounted) return;
    final HistoryChapter chapter = _data!.chapters[_chapterIndex];
    HapticFeedback.mediumImpact();
    unawaited(SoundService.instance.play(SoundEffect.chapterComplete));
    unawaited(StatsService.instance.recordHistoryChapterComplete());
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _ChapterCompleteDialog(
        chapterTitle: chapter.title,
        score: _chapterScores[_chapterIndex],
        total: chapter.questions.length,
      ),
    );
  }

  void _showSummary() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HistorySummaryScreen(data: _data!, chapterScores: _chapterScores),
      ),
    );
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_data == null) {
      return const Scaffold(body: Center(child: Text('Unable to load history.')));
    }
    if (_data!.chapters.isEmpty ||
        _data!.chapters.any((HistoryChapter chapter) => chapter.questions.isEmpty)) {
      return const Scaffold(
        body: Center(child: Text('History content is not ready yet.')),
      );
    }
    final HistoryQuestion? question = _showChoices
        ? _data!.chapters[_chapterIndex].questions[_questionIndex]
        : null;
    final bool showAdvanceButton = _isIntroStage || _isNarrationStage;
    return Scaffold(
      appBar: AppBar(title: Text(_data!.title)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (_, int index) => _MessageBubble(message: _messages[index]),
              ),
            ),
            if (question != null)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: question.choices
                      .map((QuestionChoice choice) => ActionChip(
                            label: Text(choice.text),
                            onPressed: () => _answer(choice),
                          ))
                      .toList(growable: false),
                ),
              ),
            if (showAdvanceButton)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isIntroStage ? _showNextIntro : _showNextNarration,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(_advanceButtonLabel()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _advanceButtonLabel() {
    if (_isIntroStage) {
      final bool isLast = _introIndex + 1 >= _data!.introduction.length;
      return isLast ? 'START CHAPTER 1' : 'NEXT';
    }
    final bool isLastNarration =
        _narrationIndex + 1 >= _data!.chapters[_chapterIndex].narration.length;
    return isLastNarration ? 'START CHAPTER QUIZ' : 'NEXT';
  }
}

class _ChapterCompleteDialog extends StatelessWidget {
  const _ChapterCompleteDialog({
    required this.chapterTitle,
    required this.score,
    required this.total,
  });

  final String chapterTitle;
  final int score;
  final int total;

  int get _stars {
    if (total == 0) return 0;
    final double ratio = score / total;
    if (ratio >= 0.99) return 3;
    if (ratio >= 0.6) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (BuildContext context, double value, Widget? child) =>
                  Transform.scale(scale: value, child: child),
              child: Icon(Icons.emoji_events_rounded, size: 56, color: scheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Chapter Complete!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(chapterTitle, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                3,
                (int index) => Icon(
                  Icons.star_rounded,
                  size: 32,
                  color: index < _stars ? Colors.amber : scheme.outlineVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('$score / $total correct', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                },
                child: const Text('CONTINUE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class HistorySummaryScreen extends StatelessWidget {
  const HistorySummaryScreen({super.key, required this.data, required this.chapterScores});

  final VillasisHistoryData data;
  final List<int> chapterScores;

  @override
  Widget build(BuildContext context) {
    final int total = data.chapters.fold<int>(0, (int sum, HistoryChapter chapter) => sum + chapter.questions.length);
    final int score = chapterScores.fold<int>(0, (int sum, int chapterScore) => sum + chapterScore);
    return Scaffold(
      appBar: AppBar(title: const Text('Story Complete')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Icon(Icons.auto_stories_rounded, size: 44, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('$score / $total', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 4),
                  const Text('Questions answered correctly'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (int index = 0; index < data.chapters.length; index++)
            ListTile(
              leading: Icon(Icons.bookmark_rounded, color: Theme.of(context).colorScheme.primary),
              title: Text(data.chapters[index].title),
              trailing: Text('${chapterScores[index]} / ${data.chapters[index].questions.length}'),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
            icon: const Icon(Icons.home_rounded),
            label: const Text('HOME'),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    this.guideName = '',
    this.isPlayer = false,
    this.isLabel = false,
  });

  final String text;
  final String guideName;
  final bool isPlayer;
  final bool isLabel;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (message.isLabel) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(message.text, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
        ),
      );
    }
          return Align(
      alignment: message.isPlayer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: message.isPlayer ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: message.isPlayer ? null : Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!message.isPlayer)
              Text(
                message.guideName,
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            _TypewriterText(
              text: message.text,
              enabled: !message.isPlayer,
              style: TextStyle(
                color: message.isPlayer ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  const _TypewriterText({
    required this.text,
    required this.style,
    required this.enabled,
  });

  final String text;
  final TextStyle style;
  final bool enabled;

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  Timer? _timer;
  int _visibleCharacters = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) {
      _visibleCharacters = widget.text.length;
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 18), (Timer timer) {
      if (_visibleCharacters >= widget.text.length) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() => _visibleCharacters++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.text.substring(0, _visibleCharacters), style: widget.style);
  }
}