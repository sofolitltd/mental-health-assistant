import 'dart:convert';

class TestOption {
  final String label;
  final int value;

  const TestOption({required this.label, required this.value});

  factory TestOption.fromJson(Map<String, dynamic> json) {
    return TestOption(
      label: json['label'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}

class ShowIfCondition {
  final int questionId;
  final int value;

  const ShowIfCondition({required this.questionId, required this.value});

  factory ShowIfCondition.fromJson(Map<String, dynamic> json) {
    return ShowIfCondition(
      questionId: json['questionId'] as int,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'questionId': questionId, 'value': value};
}

class TestQuestion {
  final int id;
  final String text;
  final String scale;
  final ShowIfCondition? showIf;

  const TestQuestion({
    required this.id,
    required this.text,
    required this.scale,
    this.showIf,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    final showIfJson = json['showIf'] as Map<String, dynamic>?;
    return TestQuestion(
      id: json['id'] as int,
      text: json['text'] as String,
      scale: json['scale'] as String? ?? 'general',
      showIf: showIfJson != null ? ShowIfCondition.fromJson(showIfJson) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'scale': scale,
    if (showIf != null) 'showIf': showIf!.toJson(),
  };
}

class AssessmentTest {
  final String testId;
  final String testName;
  final String? instruction;
  final List<String> scales;
  final List<TestOption> options;
  final List<TestQuestion> questions;

  const AssessmentTest({
    required this.testId,
    required this.testName,
    this.instruction,
    required this.scales,
    required this.options,
    required this.questions,
  });

  factory AssessmentTest.fromJson(Map<String, dynamic> json) {
    return AssessmentTest(
      testId: json['testId'] as String,
      testName: json['testName'] as String,
      instruction: json['instruction'] as String?,
      scales: List<String>.from(json['scales'] as List),
      options: (json['options'] as List)
          .map((o) => TestOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      questions: (json['questions'] as List)
          .map((q) => TestQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'testId': testId,
        'testName': testName,
        if (instruction != null) 'instruction': instruction,
        'scales': scales,
        'options': options.map((o) => o.toJson()).toList(),
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  static AssessmentTest fromJsonString(String jsonString) {
    return AssessmentTest.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }
}
