import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assessment_engine/data/assessment_session_repository.dart';
import '../../../assessment_engine/domain/assessment_session.dart';
import '../../../clients/domain/models/client.dart';
import '../../../clients/domain/session.dart';
import '../../../clients/presentation/providers/client_detail_providers.dart';
import '../../../clients/presentation/providers/clients_provider.dart';

part 'dashboard_providers.g.dart';

@riverpod
Future<List<Session>> allSessions(ref) async {
  final repo = ref.read(sessionRepositoryProvider);
  return repo.getAllSessions();
}

@riverpod
Future<List<AssessmentSession>> allAssessmentSessions(ref) async {
  final repo = ref.read(assessmentSessionRepositoryProvider);
  return repo.getAllSessions();
}

@riverpod
Future<DashboardData> dashboardData(ref) async {
  final clientsAsync = ref.watch(clientsProvider);
  final clients = clientsAsync.value ?? [];
  final clientIds = clients.map((c) => c.id).toSet();

  final List<Session> allSessions = await ref.watch(allSessionsProvider.future);
  final List<Session> sessions = allSessions.where((Session s) {
    return clientIds.contains(s.clientId);
  }).toList();

  final List<AssessmentSession> allAssessments = await ref.watch(allAssessmentSessionsProvider.future);
  final List<AssessmentSession> assessments = allAssessments.where((AssessmentSession a) {
    return clientIds.contains(a.clientId);
  }).toList();

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = todayStart.subtract(Duration(days: todayStart.weekday - 1));

  final List<Session> todaySessions = sessions.where((Session s) {
    return s.date.isAfter(todayStart.subtract(const Duration(hours: 1))) &&
        s.date.isBefore(todayStart.add(const Duration(days: 1))) &&
        s.status != 'cancelled';
  }).toList()
    ..sort((Session a, Session b) => a.date.compareTo(b.date));

  final int weekSessions = sessions.where((Session s) {
    return s.date.isAfter(weekStart) && s.status == 'completed';
  }).length;

  final List<Session> recentSessions = sessions.where((Session s) {
    return s.status == 'completed';
  }).toList()
    ..sort((Session a, Session b) => b.createdAt.compareTo(a.createdAt));

  final recentClientIds = <String>{};
  final recentClients = <Client>[];
  for (final s in recentSessions) {
    if (recentClientIds.length >= 5) break;
    if (recentClientIds.add(s.clientId)) {
      final client = clients.where((Client c) => c.id == s.clientId).firstOrNull;
      if (client != null) recentClients.add(client);
    }
  }

  final unreviewedAssessments = assessments.where((a) => !a.reviewed).toList();

  final clientScores = <String, List<AssessmentSession>>{};
  for (final a in unreviewedAssessments) {
    clientScores.putIfAbsent(a.clientId, () => []).add(a);
  }

  final clientAliasMap = {for (final c in clients) c.id: c.aliasCode};

  final highRiskAlerts = <AssessmentSession>[];
  for (final entry in clientScores.entries) {
    final clientAssessments = entry.value
      ..sort((AssessmentSession a, AssessmentSession b) => b.createdAt.compareTo(a.createdAt));
    final latest = clientAssessments.first;
    for (final score in latest.scores.values) {
      if (score.severity == 'High Risk' ||
          score.severity == 'Severe' ||
          score.severity == 'Extremely Severe' ||
          score.severity == 'Moderate Risk') {
        final alias = clientAliasMap[latest.clientId] ?? '';
        highRiskAlerts.add(AssessmentSession(
          sessionId: latest.sessionId,
          psychologistId: latest.psychologistId,
          clientId: latest.clientId,
          clientAlias: alias.isNotEmpty ? alias : latest.clientAlias,
          testId: latest.testId,
          createdAt: latest.createdAt,
          rawResponses: latest.rawResponses,
          scores: latest.scores,
          linkedSessionId: latest.linkedSessionId,
        ));
        break;
      }
    }
  }
  highRiskAlerts.sort((AssessmentSession a, AssessmentSession b) => b.createdAt.compareTo(a.createdAt));

  final int weekAssessments = assessments.where((AssessmentSession a) {
    return a.createdAt.isAfter(weekStart);
  }).length;

  return DashboardData(
    clientCount: clients.length,
    todaySessions: todaySessions,
    weekSessionCount: weekSessions,
    weekAssessmentCount: weekAssessments,
    recentClients: recentClients,
    highRiskAlerts: highRiskAlerts.take(5).toList(),
    newClientsThisWeek: clients.where((Client c) {
      return c.createdAt.isAfter(weekStart);
    }).length,
  );
}

class DashboardData {
  final int clientCount;
  final List<Session> todaySessions;
  final int weekSessionCount;
  final int weekAssessmentCount;
  final List<Client> recentClients;
  final List<AssessmentSession> highRiskAlerts;
  final int newClientsThisWeek;

  const DashboardData({
    required this.clientCount,
    required this.todaySessions,
    required this.weekSessionCount,
    required this.weekAssessmentCount,
    required this.recentClients,
    required this.highRiskAlerts,
    required this.newClientsThisWeek,
  });
}
