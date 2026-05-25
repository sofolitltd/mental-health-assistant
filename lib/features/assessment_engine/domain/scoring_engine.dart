import 'assessment_models.dart';

class ScoreResult {
  final int rawScore;
  final int maxScore;
  final String severity;
  final String scale;
  final String? interpretation;

  const ScoreResult({
    required this.rawScore,
    required this.maxScore,
    required this.severity,
    required this.scale,
    this.interpretation,
  });

  Map<String, dynamic> toJson() => {
    'rawScore': rawScore,
    'maxScore': maxScore,
    'severity': severity,
    'scale': scale,
    'interpretation': interpretation,
  };

  factory ScoreResult.fromJson(Map<String, dynamic> json) {
    return ScoreResult(
      rawScore: json['rawScore'] as int,
      maxScore: json['maxScore'] as int? ?? 42,
      severity: json['severity'] as String,
      scale: json['scale'] as String,
      interpretation: json['interpretation'] as String?,
    );
  }
}

List<SeverityThreshold> getSeverityThresholds(String testId, String scale) {
  if (testId.startsWith('dass21')) {
    switch (scale) {
      case 'depression':
        return const [
          SeverityThreshold('Normal', 0, 9),
          SeverityThreshold('Mild', 10, 13),
          SeverityThreshold('Moderate', 14, 20),
          SeverityThreshold('Severe', 21, 27),
          SeverityThreshold('Extremely Severe', 28, 42),
        ];
      case 'anxiety':
        return const [
          SeverityThreshold('Normal', 0, 7),
          SeverityThreshold('Mild', 8, 9),
          SeverityThreshold('Moderate', 10, 14),
          SeverityThreshold('Severe', 15, 19),
          SeverityThreshold('Extremely Severe', 20, 42),
        ];
      case 'stress':
        return const [
          SeverityThreshold('Normal', 0, 14),
          SeverityThreshold('Mild', 15, 18),
          SeverityThreshold('Moderate', 19, 25),
          SeverityThreshold('Severe', 26, 33),
          SeverityThreshold('Extremely Severe', 34, 42),
        ];
    }
  }
  if (testId.startsWith('srq20')) {
    return const [
      SeverityThreshold('Normal', 0, 7),
      SeverityThreshold('Probable Mental Distress', 8, 20),
    ];
  }
  if (testId.startsWith('cspt')) {
    // Each level is one ordinal step (0 = No Risk … 3 = High Risk)
    return const [
      SeverityThreshold('No Risk Indicated', 0, 0),
      SeverityThreshold('Low Risk', 1, 1),
      SeverityThreshold('Moderate Risk', 2, 2),
      SeverityThreshold('High Risk', 3, 3),
    ];
  }
  return [];
}

class SeverityThreshold {
  final String label;
  final int min;
  final int max;

  const SeverityThreshold(this.label, this.min, this.max);
}

// ─── Abstract base ────────────────────────────────────────────────────────────
abstract class ScoringEngine {
  Map<String, ScoreResult> calculate(
    Map<int, int> responses,
    List<TestQuestion> questions,
  );
}

// ─── Factory ─────────────────────────────────────────────────────────────────
class ScoringEngineFactory {
  static ScoringEngine getEngine(String testId) {
    if (testId.startsWith('dass21')) {
      return Dass21ScoringAdapter();
    } else if (testId.startsWith('srq20')) {
      return Srq20ScoringAdapter();
    } else if (testId.startsWith('cspt')) {
      return CsptScoringAdapter();
    }
    throw UnimplementedError('No scoring engine available for test: $testId');
  }
}

// ─── DASS-21 ─────────────────────────────────────────────────────────────────
class Dass21ScoringAdapter implements ScoringEngine {
  @override
  Map<String, ScoreResult> calculate(
    Map<int, int> responses,
    List<TestQuestion> questions,
  ) {
    int depression = 0;
    int anxiety = 0;
    int stress = 0;

    for (final question in questions) {
      final response = responses[question.id] ?? 0;
      switch (question.scale) {
        case 'depression':
          depression += response;
          break;
        case 'anxiety':
          anxiety += response;
          break;
        case 'stress':
          stress += response;
          break;
      }
    }

    // DASS-21 multiplies by 2 to get DASS-42 equivalent scores
    final dScore = depression * 2;
    final aScore = anxiety * 2;
    final sScore = stress * 2;

    return {
      'depression': ScoreResult(
        rawScore: dScore,
        maxScore: 42,
        severity: _getDepressionSeverity(dScore),
        scale: 'depression',
        interpretation: _getDepressionInterpretation(dScore),
      ),
      'anxiety': ScoreResult(
        rawScore: aScore,
        maxScore: 42,
        severity: _getAnxietySeverity(aScore),
        scale: 'anxiety',
        interpretation: _getAnxietyInterpretation(aScore),
      ),
      'stress': ScoreResult(
        rawScore: sScore,
        maxScore: 42,
        severity: _getStressSeverity(sScore),
        scale: 'stress',
        interpretation: _getStressInterpretation(sScore),
      ),
    };
  }

  String _getDepressionSeverity(int score) {
    if (score <= 9) return 'Normal';
    if (score <= 13) return 'Mild';
    if (score <= 20) return 'Moderate';
    if (score <= 27) return 'Severe';
    return 'Extremely Severe';
  }

  String _getDepressionInterpretation(int score) {
    if (score <= 9) return 'বিষণ্ণতার কোনো লক্ষণ নেই। বর্তমান অবস্থা স্বাভাবিক।';
    if (score <= 13) return 'হালকা বিষণ্ণতা লক্ষণ দেখা যাচ্ছে। নিয়মিত পর্যবেক্ষণ এবং মানসিক সহায়তা প্রদান করুন।';
    if (score <= 20) return 'মাঝারি বিষণ্ণতা লক্ষণ। পেশাদার মানসিক স্বাস্থ্য মূল্যায়নের পরামর্শ দিন।';
    if (score <= 27) return 'তীব্র বিষণ্ণতা লক্ষণ। ক্লিনিক্যাল মূল্যায়ন এবং চিকিৎসা প্রয়োজন।';
    return 'অত্যন্ত তীব্র বিষণ্ণতা লক্ষণ। অবিলম্বে ক্লিনিক্যাল মূল্যায়ন এবং চিকিৎসা প্রয়োজন।';
  }

  String _getAnxietySeverity(int score) {
    if (score <= 7) return 'Normal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    if (score <= 19) return 'Severe';
    return 'Extremely Severe';
  }

  String _getAnxietyInterpretation(int score) {
    if (score <= 7) return 'উদ্বেগের কোনো লক্ষণ নেই। বর্তমান অবস্থা স্বাভাবিক।';
    if (score <= 9) return 'হালকা উদ্বেগ লক্ষণ দেখা যাচ্ছে। নিয়মিত পর্যবেক্ষণ করুন।';
    if (score <= 14) return 'মাঝারি উদ্বেগ লক্ষণ। পেশাদার মানসিক স্বাস্থ্য মূল্যায়নের পরামর্শ দিন।';
    if (score <= 19) return 'তীব্র উদ্বেগ লক্ষণ। ক্লিনিক্যাল মূল্যায়ন এবং চিকিৎসা প্রয়োজন।';
    return 'অত্যন্ত তীব্র উদ্বেগ লক্ষণ। অবিলম্বে ক্লিনিক্যাল মূল্যায়ন প্রয়োজন।';
  }

  String _getStressSeverity(int score) {
    if (score <= 14) return 'Normal';
    if (score <= 18) return 'Mild';
    if (score <= 25) return 'Moderate';
    if (score <= 33) return 'Severe';
    return 'Extremely Severe';
  }

  String _getStressInterpretation(int score) {
    if (score <= 14) return 'মানসিক চাপের কোনো লক্ষণ নেই। বর্তমান অবস্থা স্বাভাবিক।';
    if (score <= 18) return 'হালকা মানসিক চাপ লক্ষণ দেখা যাচ্ছে। নিয়মিত পর্যবেক্ষণ এবং বিশ্রাম নিশ্চিত করুন।';
    if (score <= 25) return 'মাঝারি মানসিক চাপ লক্ষণ। পেশাদার মানসিক স্বাস্থ্য মূল্যায়নের পরামর্শ দিন।';
    if (score <= 33) return 'তীব্র মানসিক চাপ লক্ষণ। ক্লিনিক্যাল মূল্যায়ন প্রয়োজন।';
    return 'অত্যন্ত তীব্র মানসিক চাপ লক্ষণ। অবিলম্বে ক্লিনিক্যাল মূল্যায়ন এবং হস্তক্ষেপ প্রয়োজন।';
  }
}

// ─── SRQ-20 ──────────────────────────────────────────────────────────────────
class Srq20ScoringAdapter implements ScoringEngine {
  @override
  Map<String, ScoreResult> calculate(
    Map<int, int> responses,
    List<TestQuestion> questions,
  ) {
    int total = 0;
    for (final q in questions) {
      total += responses[q.id] ?? 0;
    }
    return {
      'general': ScoreResult(
        rawScore: total,
        maxScore: questions.length,
        severity: _getSeverity(total),
        scale: 'general',
        interpretation: total >= 8
            ? 'স্কোর ≥ ৮ ইঙ্গিত দেয় সম্ভাব্য মানসিক সমস্যা। ক্লিনিক্যাল ফলো-আপ প্রয়োজন।'
            : 'স্কোর থ্রেশহোল্ডের নিচে। মনিটরিং চালিয়ে যান।',
      ),
    };
  }

  String _getSeverity(int score) {
    if (score < 8) return 'Normal';
    return 'Probable Mental Distress';
  }
}

// ─── C-SSRS ──────────────────────────────────────────────────────────────────
/// Implements the Columbia Suicide Severity Rating Scale (Screen Version)
/// pattern-based scoring per official guidelines.
///
/// Risk levels are determined by the PATTERN of Yes answers, NOT a numeric sum:
///   High Risk    : Q4==Yes  OR  Q5==Yes  OR  (Q6==Yes AND Q7==Yes)
///   Moderate Risk: Q2==Yes  AND Q3==Yes  (but not High Risk)
///   Low Risk     : Q1==Yes  OR  Q2==Yes  (but not Moderate/High)
///   No Risk      : all No
class CsptScoringAdapter implements ScoringEngine {
  @override
  Map<String, ScoreResult> calculate(
    Map<int, int> responses,
    List<TestQuestion> questions,
  ) {
    final q1 = responses[1] == 1;
    final q2 = responses[2] == 1;
    final q3 = responses[3] == 1;
    final q4 = responses[4] == 1;
    final q5 = responses[5] == 1;
    final q6 = responses[6] == 1;
    final q7 = responses[7] == 1; // within last 3 months

    final severity = _getSeverity(q1, q2, q3, q4, q5, q6, q7);
    final rawScore = _severityToScore(severity);
    final interpretation = _getInterpretation(severity);

    return {
      'suicide_risk': ScoreResult(
        rawScore: rawScore,
        maxScore: 3,
        severity: severity,
        scale: 'suicide_risk',
        interpretation: interpretation,
      ),
    };
  }

  String _getSeverity(
    bool q1, bool q2, bool q3, bool q4, bool q5, bool q6, bool q7,
  ) {
    // High Risk: detailed plan/intent, or recent preparatory behaviour/attempt
    if (q4 || q5 || (q6 && q7)) return 'High Risk';
    // Moderate Risk: active ideation with some method in mind
    if (q2 && q3) return 'Moderate Risk';
    // Low Risk: passive death wish or active ideation without method/intent
    if (q1 || q2) return 'Low Risk';
    // No Risk: all No
    return 'No Risk Indicated';
  }

  int _severityToScore(String severity) {
    switch (severity) {
      case 'High Risk':     return 3;
      case 'Moderate Risk': return 2;
      case 'Low Risk':      return 1;
      default:              return 0;
    }
  }

  String _getInterpretation(String severity) {
    switch (severity) {
      case 'High Risk':
        return 'উচ্চ ঝুঁকি শনাক্ত হয়েছে। অবিলম্বে ক্লিনিক্যাল মূল্যায়ন এবং সংকট হস্তক্ষেপ প্রয়োজন।';
      case 'Moderate Risk':
        return 'মাঝারি ঝুঁকি শনাক্ত হয়েছে। পেশাদার মানসিক স্বাস্থ্য মূল্যায়নের জন্য রেফার করুন।';
      case 'Low Risk':
        return 'কম ঝুঁকি শনাক্ত হয়েছে। নিয়মিত পর্যবেক্ষণ এবং সহায়তা প্রদান করুন।';
      default:
        return 'কোনো সক্রিয় আত্মহত্যামূলক চিন্তা বা আচরণ রিপোর্ট করা হয়নি।';
    }
  }
}
