import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/assessment_models.dart';

part 'assessment_repository.g.dart';

@riverpod
AssessmentRepository assessmentRepository(ref) {
  return AssessmentRepository();
}

class AssessmentRepository {
  Future<AssessmentTest> loadTest(String testId) async {
    final String response = await rootBundle.loadString(
      'assets/data/$testId.json',
    );
    final data = json.decode(response) as Map<String, dynamic>;
    return AssessmentTest.fromJson(data);
  }

  Future<List<Map<String, String>>> getAvailableTests() async {
    return [
      {
        'id': 'dass21_bn',
        'name': 'DASS-21 (Bangla)',
        'description': 'Depression, Anxiety and Stress Scale (21 Items)',
      },
      {
        'id': 'srq20_bn',
        'name': 'SRQ-20 (Bangla)',
        'description': 'Self-Reporting Questionnaire',
      },
      {
        'id': 'cspt_bn',
        'name': 'C-SSRS (Bangla)',
        'description': 'Columbia Suicide Severity Rating Scale Screener',
      },
    ];
  }
}
