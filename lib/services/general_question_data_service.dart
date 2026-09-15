import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/general_question_model.dart';

class GeneralQuestionDataService {
  const GeneralQuestionDataService();

  Future<List<GeneralQuestion>> load() async {
    final String rawJson = await rootBundle.loadString(
      'assets/data/general_questions.json',
    );
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Question pool must be a JSON object.');
    }
    return (decoded['questions'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(GeneralQuestion.fromJson)
        .toList(growable: false);
  }
}