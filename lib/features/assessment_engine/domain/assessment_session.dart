import 'scoring_engine.dart';

class AssessmentSession {
  final String sessionId;
  final String organizationId;
  final String psychologistId;
  final String clientId;
  final String clientAlias;
  final String testId;
  final DateTime createdAt;
  final Map<int, int> rawResponses;
  final Map<String, ScoreResult> scores;
  final String? linkedSessionId;
  final bool reviewed;

  const AssessmentSession({
    required this.sessionId,
    this.organizationId = '',
    required this.psychologistId,
    required this.clientId,
    required this.clientAlias,
    required this.testId,
    required this.createdAt,
    required this.rawResponses,
    required this.scores,
    this.linkedSessionId,
    this.reviewed = false,
  });

  Map<String, dynamic> toJson() => {
        'organizationId': organizationId,
        'sessionId': sessionId,
        'psychologistId': psychologistId,
        'clientId': clientId,
        'clientAlias': clientAlias,
        'testId': testId,
        'createdAt': createdAt.toIso8601String(),
        'linkedSessionId': linkedSessionId,
        'rawResponses': rawResponses.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
        'scores': scores.map((k, v) => MapEntry(k, v.toJson())),
        'reviewed': reviewed,
      };

  factory AssessmentSession.fromJson(Map<String, dynamic> json) {
    final rawMap = json['rawResponses'] as Map<String, dynamic>? ?? {};
    final scoresMap = json['scores'] as Map<String, dynamic>? ?? {};
    return AssessmentSession(
      sessionId: json['sessionId'] as String,
      organizationId: json['organizationId'] as String? ?? '',
      psychologistId: json['psychologistId'] as String? ?? 'unknown',
      clientId: json['clientId'] as String,
      clientAlias: json['clientAlias'] as String? ?? '',
      testId: json['testId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      linkedSessionId: json['linkedSessionId'] as String?,
      rawResponses: rawMap.map(
        (k, v) => MapEntry(int.parse(k), v as int),
      ),
      scores: scoresMap.map(
        (k, v) => MapEntry(
          k,
          ScoreResult.fromJson(v as Map<String, dynamic>),
        ),
      ),
      reviewed: json['reviewed'] as bool? ?? false,
    );
  }
}
