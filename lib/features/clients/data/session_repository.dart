import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../domain/session.dart';

class SessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _sessions => _firestore.collection('sessions');

  Future<void> addSession(Session session) async {
    await _sessions.add(session.toMap());
  }

  Future<void> updateSession(Session session) async {
    await _sessions.doc(session.id).update(session.toMap());
  }

  Future<void> deleteSession(String id) async {
    await _sessions.doc(id).delete();
  }

  Future<Session?> getSessionById(String id) async {
    final doc = await _sessions.doc(id).get();
    if (!doc.exists) return null;
    return Session.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Stream<List<Session>> watchSessionsByClientId(String clientId) {
    return _sessions
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Session.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList())
        .handleError((error) {
          debugPrint('═══ Firestore Index Required ═══');
          debugPrint('$error');
          debugPrint('════════════════════════════════');
        });
  }

  Future<List<Session>> getAllSessions() async {
    final snapshot = await _sessions.get();
    return snapshot.docs
        .map((doc) => Session.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<String>> getSessionIdsByClientId(String clientId) async {
    final snapshot = await _sessions
        .where('clientId', isEqualTo: clientId)
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
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
}
