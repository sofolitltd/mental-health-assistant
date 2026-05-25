import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/assessment_session.dart';
import '../../data/assessment_session_repository.dart';

part 'assessment_session_providers.g.dart';

@riverpod
Future<List<AssessmentSession>> clientAssessmentSessions(ref, String clientId) async {
  final repository = ref.watch(assessmentSessionRepositoryProvider);
  return repository.getSessionsByClientId(clientId);
}

final linkedAssessmentSessionsProvider = FutureProvider.family<List<AssessmentSession>, String>(
  (ref, sessionId) async {
    final repository = ref.watch(assessmentSessionRepositoryProvider);
    return repository.getSessionsByLinkedSessionId(sessionId);
  },
);
