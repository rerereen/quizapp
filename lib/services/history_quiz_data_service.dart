import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/history_quiz_models.dart';

class HistoryQuizDataService {
  const HistoryQuizDataService();

  Future<VillasisHistoryData> load(String assetPath) async {
    final String rawJson = await rootBundle.loadString(assetPath);
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('History data must be a JSON object.');
    }
    return VillasisHistoryData.fromJson(decoded);
  }
}