import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assessment_notifier.g.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class AssessmentState {
  final Map<int, int> responses;

  const AssessmentState({this.responses = const {}});

  AssessmentState copyWith({Map<int, int>? responses}) {
    return AssessmentState(responses: responses ?? this.responses);
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────

@riverpod
class Assessment extends _$Assessment {
  @override
  AssessmentState build() => const AssessmentState();

  void setResponse(int questionId, int value) {
    final updated = Map<int, int>.from(state.responses);
    updated[questionId] = value;
    state = state.copyWith(responses: updated);
  }

  void clearResponse(int questionId) {
    final updated = Map<int, int>.from(state.responses)..remove(questionId);
    state = state.copyWith(responses: updated);
  }

  void reset() {
    state = const AssessmentState();
  }

  /// [visibleCount] is the number of currently visible questions (skip-logic aware).
  double getProgress(int visibleCount) {
    if (visibleCount == 0) return 0;
    final answered = state.responses.length;
    return (answered / visibleCount).clamp(0.0, 1.0);
  }

  /// [visibleCount] is the number of currently visible questions (skip-logic aware).
  bool isComplete(int visibleCount) {
    if (visibleCount == 0) return false;
    return state.responses.length >= visibleCount;
  }
}
