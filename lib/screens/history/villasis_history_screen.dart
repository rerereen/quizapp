import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/history_quiz_models.dart';
import '../../services/history_quiz_data_service.dart';

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
      await _playChapter();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _playChapter() async {
    final VillasisHistoryData data = _data!;
    final HistoryChapter chapter = data.chapters[_chapterIndex];
    setState(() {
      _isNarrationStage = true;
      _narrationIndex = 0;
    });
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
    final HistoryChapter chapter = _data!.chapters[_chapterIndex];
    if (_narrationIndex + 1 < chapter.narration.length) {
      setState(() => _narrationIndex++);
      await _addGuideMessage(chapter.narration[_narrationIndex]);
      return;
    }

    setState(() {
      _isNarrationStage = false;
      _messages.clear();
    });
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

  Future<void> _answer(QuestionChoice choice) async {
    if (!_showChoices) return;
    final HistoryQuestion question = _data!.chapters[_chapterIndex]
        .questions[_questionIndex];
    final bool isCorrect = choice.id == question.correctChoiceId;
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
      await _askCurrentQuestion();
    } else if (_chapterIndex + 1 < _data!.chapters.length) {
      setState(() {
        _chapterIndex++;
        _questionIndex = 0;
        _messages.clear();
      });
      await _playChapter();
    } else {
      _showSummary();
    }
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
            if (_isNarrationStage)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showNextNarration,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _narrationIndex + 1 <
                              _data!.chapters[_chapterIndex].narration.length
                          ? 'NEXT'
                          : 'START CHAPTER QUIZ',
                    ),
                  ),
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
          color: message.isPlayer ? scheme.primary : Colors.white,
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
                color: message.isPlayer ? Colors.white : scheme.onSurface,
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