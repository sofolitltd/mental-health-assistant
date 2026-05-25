import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/assessment_session.dart';

part 'assessment_session_repository.g.dart';

@Riverpod(keepAlive: true)
AssessmentSessionRepository assessmentSessionRepository(ref) {
  return AssessmentSessionRepository();
}

class AssessmentSessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _sessions =>
      _firestore.collection('assessment_sessions');

  Future<void> saveSession(AssessmentSession session) async {
    await _sessions.doc(session.sessionId).set(session.toJson());
  }

  Future<List<AssessmentSession>> getSessionsByClientId(
      String clientId) async {
    final snapshot = await _sessions
        .where('clientId', isEqualTo: clientId)
        .get();
    return snapshot.docs
        .map((doc) =>
            AssessmentSession.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<AssessmentSession?> getSessionById(String sessionId) async {
    final doc = await _sessions.doc(sessionId).get();
    if (!doc.exists) return null;
    return AssessmentSession.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<List<AssessmentSession>> getAllSessions() async {
    final snapshot = await _sessions.get();
    return snapshot.docs
        .map((doc) =>
            AssessmentSession.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsReviewed(String sessionId) async {
    await _sessions.doc(sessionId).update({'reviewed': true});
  }

  Future<void> markAsUnreviewed(String sessionId) async {
    await _sessions.doc(sessionId).update({'reviewed': false});
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessions.doc(sessionId).delete();
  }

  Future<void> deleteSessionsByClientId(String clientId) async {
    final snapshot = await _sessions
        .where('clientId', isEqualTo: clientId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<List<AssessmentSession>> getSessionsByLinkedSessionId(
      String linkedSessionId) async {
    final snapshot = await _sessions
        .where('linkedSessionId', isEqualTo: linkedSessionId)
        .get();
    return snapshot.docs
        .map((doc) =>
            AssessmentSession.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
