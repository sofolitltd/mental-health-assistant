import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '/features/assessment_engine/domain/assessment_session.dart';
import '/features/clients/domain/models/client.dart';
import '/features/contacts/presentation/providers/contacts_providers.dart';
import '/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'admin_auth_provider.dart';

part 'admin_data_provider.g.dart';

@riverpod
String? adminEffectiveOrgId(Ref ref) {
  final role = ref.watch(adminRoleProvider).asData?.value ?? 'admin';
  if (role == 'admin') {
    return ref.watch(adminOrganizationIdProvider).asData?.value ?? '';
  }
  return ref.watch(adminOrgFilterProvider);
}

Future<List<Client>> _fetchClientsByOrg(String? orgId) async {
  final Query<Map<String, dynamic>> base =
      FirebaseFirestore.instance.collection('clients');
  final query = orgId != null && orgId.isNotEmpty
      ? base.where('organizationId', isEqualTo: orgId)
      : base;
  final snapshot = await query.get();
  final clients = snapshot.docs
      .map((doc) => Client.fromMap(doc.data(), doc.id))
      .toList();
  clients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return clients;
}

@riverpod
Future<List<Client>> adminFilteredClients(Ref ref) async {
  try {
    final orgId = ref.watch(adminEffectiveOrgIdProvider);
    return _fetchClientsByOrg(orgId);
  } catch (_) {
    return [];
  }
}

@Riverpod(keepAlive: true)
class AdminDashboardData extends _$AdminDashboardData {
  @override
  Future<AdminDashboardStats> build() async {
    try {
      final orgId = ref.watch(adminEffectiveOrgIdProvider);
      final clients = ref.watch(adminFilteredClientsProvider).asData?.value ?? [];
      final allSessions = ref.watch(allSessionsProvider).asData?.value ?? [];
      final allAssessments = ref.watch(allAssessmentSessionsProvider).asData?.value ?? [];
      final allCounselors = ref.watch(allCounselorsProvider).asData?.value ?? [];

    final sessions = orgId == null || orgId.isEmpty
        ? allSessions
        : allSessions.where((s) => s.organizationId == orgId).toList();
    final assessments = orgId == null || orgId.isEmpty
        ? allAssessments
        : allAssessments.where((a) => a.organizationId == orgId).toList();
    final counselors = orgId == null || orgId.isEmpty
        ? allCounselors
        : allCounselors.where((c) => c.organizationId == orgId).toList();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: todayStart.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final weekSessions = sessions.where((s) => s.date.isAfter(weekStart)).length;
    final weekAssessments = assessments.where((a) => a.createdAt.isAfter(weekStart)).length;
    final monthSessions = sessions.where((s) => s.date.isAfter(monthStart)).length;
    final monthAssessments = assessments.where((a) => a.createdAt.isAfter(monthStart)).length;

    final unreviewedHighRisk = assessments
        .where((a) => !a.reviewed)
        .where((a) => a.scores.values.any((s) =>
            s.severity == 'High Risk' ||
            s.severity == 'Severe' ||
            s.severity == 'Extremely Severe' ||
            s.severity == 'Moderate Risk'))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final recentClients = List<Client>.from(clients)
      ..sort((a, b) {
        final aDate = a.joinDate ?? a.createdAt;
        final bDate = b.joinDate ?? b.createdAt;
        return bDate.compareTo(aDate);
      });

    final counselorClientCount = <String, int>{};
    for (final client in clients) {
      for (final cId in client.counselorIds) {
        counselorClientCount[cId] = (counselorClientCount[cId] ?? 0) + 1;
      }
    }

    return AdminDashboardStats(
      totalClients: clients.length,
      totalCounselors: counselors.length,
      totalSessions: sessions.length,
      totalAssessments: assessments.length,
      weekSessions: weekSessions,
      weekAssessments: weekAssessments,
      monthSessions: monthSessions,
      monthAssessments: monthAssessments,
      unreviewedHighRisk: unreviewedHighRisk,
      recentClients: recentClients.take(5).toList(),
      counselorClientCount: counselorClientCount,
    );
    } catch (_) {
      return const AdminDashboardStats(
        totalClients: 0,
        totalCounselors: 0,
        totalSessions: 0,
        totalAssessments: 0,
        weekSessions: 0,
        weekAssessments: 0,
        monthSessions: 0,
        monthAssessments: 0,
        unreviewedHighRisk: [],
        recentClients: [],
        counselorClientCount: {},
      );
    }
  }
}

class AdminDashboardStats {
  final int totalClients;
  final int totalCounselors;
  final int totalSessions;
  final int totalAssessments;
  final int weekSessions;
  final int weekAssessments;
  final int monthSessions;
  final int monthAssessments;
  final List<AssessmentSession> unreviewedHighRisk;
  final List<Client> recentClients;
  final Map<String, int> counselorClientCount;

  const AdminDashboardStats({
    required this.totalClients,
    required this.totalCounselors,
    required this.totalSessions,
    required this.totalAssessments,
    required this.weekSessions,
    required this.weekAssessments,
    required this.monthSessions,
    required this.monthAssessments,
    required this.unreviewedHighRisk,
    required this.recentClients,
    required this.counselorClientCount,
  });
}
