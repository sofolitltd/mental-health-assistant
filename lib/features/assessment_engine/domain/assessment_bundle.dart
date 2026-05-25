import 'scoring_engine.dart';

/// Bundle passed via GoRouter `extra` to the ResultsScreen.
class AssessmentResultBundle {
  final Map<String, ScoreResult> results;
  final String testId;
  final String? clientId;
  final Map<int, int> rawResponses;

  const AssessmentResultBundle({
    required this.results,
    required this.testId,
    this.clientId,
    required this.rawResponses,
  });
}
