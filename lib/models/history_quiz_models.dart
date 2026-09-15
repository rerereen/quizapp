class QuestionChoice {
  const QuestionChoice({required this.id, required this.text});

  final String id;
  final String text;

  factory QuestionChoice.fromJson(Map<String, dynamic> json) => QuestionChoice(
    id: (json['id'] ?? '').toString(),
    text: (json['text'] ?? '').toString(),
  );
}

class HistoryQuestion {
  const HistoryQuestion({
    required this.id,
    required this.prompt,
    required this.choices,
    required this.correctChoiceId,
    required this.feedbackCorrect,
    required this.feedbackIncorrect,
  });

  final String id;
  final String prompt;
  final List<QuestionChoice> choices;
  final String correctChoiceId;
  final String feedbackCorrect;
  final String feedbackIncorrect;

  factory HistoryQuestion.fromJson(Map<String, dynamic> json) => HistoryQuestion(
    id: (json['id'] ?? '').toString(),
    prompt: (json['prompt'] ?? '').toString(),
    choices: (json['choices'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(QuestionChoice.fromJson)
        .toList(growable: false),
    correctChoiceId: (json['correctChoiceId'] ?? '').toString(),
    feedbackCorrect: (json['feedbackCorrect'] ?? '').toString(),
    feedbackIncorrect: (json['feedbackIncorrect'] ?? '').toString(),
  );
}

class HistoryChapter {
  const HistoryChapter({
    required this.id,
    required this.title,
    required this.narration,
    required this.questions,
  });

  final String id;
  final String title;
  final List<String> narration;
  final List<HistoryQuestion> questions;

  factory HistoryChapter.fromJson(Map<String, dynamic> json) => HistoryChapter(
    id: (json['id'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    narration: (json['narration'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic item) => item.toString())
        .toList(growable: false),
    questions: (json['questions'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(HistoryQuestion.fromJson)
        .toList(growable: false),
  );
}

class VillasisHistoryData {
  const VillasisHistoryData({
    required this.id,
    required this.title,
    required this.guideName,
    required this.chapters,
  });

  final String id;
  final String title;
  final String guideName;
  final List<HistoryChapter> chapters;

  factory VillasisHistoryData.fromJson(Map<String, dynamic> json) =>
      VillasisHistoryData(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        guideName: (json['guideName'] ?? '').toString(),
        chapters: (json['chapters'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(HistoryChapter.fromJson)
            .toList(growable: false),
      );
}