import 'history_quiz_models.dart';

class GeneralQuestion {
  const GeneralQuestion({
    required this.id,
    required this.difficulty,
    required this.prompt,
    required this.choices,
    required this.correctChoiceId,
    required this.explanation,
  });

  final String id;
  final String difficulty;
  final String prompt;
  final List<QuestionChoice> choices;
  final String correctChoiceId;
  final String explanation;

  factory GeneralQuestion.fromJson(Map<String, dynamic> json) {
    return GeneralQuestion(
      id: (json['id'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? '').toString(),
      prompt: (json['prompt'] ?? '').toString(),
      choices: (json['choices'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(QuestionChoice.fromJson)
          .toList(growable: false),
      correctChoiceId: (json['correctChoiceId'] ?? '').toString(),
      explanation: (json['explanation'] ?? '').toString(),
    );
  }
}