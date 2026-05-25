import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../../assessment_engine/data/assessment_session_repository.dart';
import '../../../assessment_engine/domain/assessment_session.dart';
import '../../../clients/domain/models/client.dart';
import '../../../clients/domain/session.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final fontFamily = GoogleFonts.outfit().fontFamily!;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: MaxWidthContainer(
          child: dashboardAsync.when(
            data: (data) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  title: Text(
                    'Dashboard',
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  floating: true,
                  snap: true,
                  centerTitle: false,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (data.highRiskAlerts.isNotEmpty)
                        _HighRiskBanner(
                          alerts: data.highRiskAlerts,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          fontFamily: fontFamily,
                          onDismiss: (sessionId) =>
                              ref.read(assessmentSessionRepositoryProvider).markAsReviewed(sessionId),
                        ),
                      _QuickStats(
                        clientCount: data.clientCount,
                        weekSessionCount: data.weekSessionCount,
                        weekAssessmentCount: data.weekAssessmentCount,
                        newClientsThisWeek: data.newClientsThisWeek,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        border: border,
                        surface: surface,
                        fontFamily: fontFamily,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _TodaySchedule(
                        sessions: data.todaySessions,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        border: border,
                        surface: surface,
                        fontFamily: fontFamily,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _RecentClients(
                        clients: data.recentClients,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        border: border,
                        surface: surface,
                        fontFamily: fontFamily,
                      ),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Unable to load dashboard data.\n$err',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSecondary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HighRiskBanner extends StatelessWidget {
  final List<AssessmentSession> alerts;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final String fontFamily;
  final ValueChanged<String> onDismiss;

  const _HighRiskBanner({
    required this.alerts,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.fontFamily,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Attention Required',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...alerts.take(3).map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${a.clientAlias.isNotEmpty ? a.clientAlias : a.clientId} — ${a.scores.values.where((s) => s.severity == 'High Risk' || s.severity == 'Severe' || s.severity == 'Extremely Severe' || s.severity == 'Moderate Risk').map((s) => '${s.scale.replaceAll('_', ' ')}: ${s.severity}').join(', ')}',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => onDismiss(a.sessionId),
                  child: Icon(Icons.close, size: 16, color: Colors.red.shade300),
                ),
              ],
            ),
          )),
          if (alerts.length > 3)
            Text(
              '+${alerts.length - 3} more',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontFamily: fontFamily,
              ),
            ),
        ],
      ),
    );
  }
}

class _TodaySchedule extends StatelessWidget {
  final List<Session> sessions;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final String fontFamily;

  const _TodaySchedule({
    required this.sessions,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "Today's Schedule",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('EEE, MMM d').format(DateTime.now()),
                    style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily),
                  ),
                ],
              ),
            ),
            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(Icons.event_busy_rounded, size: 18, color: textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'No sessions scheduled for today',
                      style: TextStyle(color: textSecondary, fontSize: 14, fontFamily: fontFamily),
                    ),
                  ],
                ),
              )
            else
              ...sessions.map((s) => _SessionTile(
                session: s,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                border: border,
                fontFamily: fontFamily,
              )),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final String fontFamily;

  const _SessionTile({
    required this.session,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.fontFamily,
  });

  Color _statusColor() {
    switch (session.status) {
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return AppColors.primary;
    }
  }

  String? _durationText() {
    if (session.startTime == null || session.endTime == null) return null;
    final diff = session.endTime!.difference(session.startTime!);
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final duration = _durationText();
    return InkWell(
      onTap: () => context.go('/clients/${session.clientId}/sessions/${session.id}', extra: {'session': session}),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.roundedSm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    session.startTime != null
                        ? DateFormat('HH:mm').format(session.startTime!)
                        : '--:--',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (session.endTime != null)
                    Text(
                      DateFormat('HH:mm').format(session.endTime!),
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.primary.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.clientAlias.isNotEmpty ? session.clientAlias : 'Client',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Row(
                    children: [
                      if (session.title.isNotEmpty)
                        Flexible(
                          child: Text(
                            session.title,
                            style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (duration != null && session.title.isNotEmpty)
                        Text(' · ', style: TextStyle(fontSize: 12, color: textSecondary)),
                      if (duration != null)
                        Text(
                          duration,
                          style: TextStyle(fontSize: 11, color: textSecondary.withOpacity(0.7), fontFamily: fontFamily),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor().withOpacity(0.12),
                borderRadius: AppRadius.roundedSm,
              ),
              child: Text(
                session.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _statusColor(),
                  fontFamily: fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final int clientCount;
  final int weekSessionCount;
  final int weekAssessmentCount;
  final int newClientsThisWeek;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final String fontFamily;

  const _QuickStats({
    required this.clientCount,
    required this.weekSessionCount,
    required this.weekAssessmentCount,
    required this.newClientsThisWeek,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _StatCard(
              icon: Icons.people_outline_rounded,
              label: 'Clients',
              value: '$clientCount',
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              surface: surface,
              fontFamily: fontFamily,
            )),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatCard(
              icon: Icons.event_available_rounded,
              label: 'Sessions',
              value: '$weekSessionCount',
              sublabel: 'this week',
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              surface: surface,
              fontFamily: fontFamily,
            )),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatCard(
              icon: Icons.assignment_outlined,
              label: 'Assessments',
              value: '$weekAssessmentCount',
              sublabel: 'this week',
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              surface: surface,
              fontFamily: fontFamily,
            )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sublabel;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final String fontFamily;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.sublabel,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              fontFamily: fontFamily,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily),
          ),
          if (sublabel != null)
            Text(
              sublabel!,
              style: TextStyle(fontSize: 10, color: textSecondary.withOpacity(0.7), fontFamily: fontFamily),
            ),
        ],
      ),
    );
  }
}

class _RecentClients extends StatelessWidget {
  final List<Client> clients;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final String fontFamily;

  const _RecentClients({
    required this.clients,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 18, color: textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Recent Clients',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => context.go('/clients'),
                    borderRadius: AppRadius.roundedSm,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...clients.map((c) => _RecentClientTile(
              client: c,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              fontFamily: fontFamily,
            )),
          ],
        ),
      ),
    );
  }
}

class _RecentClientTile extends StatelessWidget {
  final Client client;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final String fontFamily;

  const _RecentClientTile({
    required this.client,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/clients/${client.id}/about'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.roundedSm,
              ),
              child: Text(
                client.aliasCode.isNotEmpty ? client.aliasCode[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: fontFamily,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.aliasCode,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    client.dateOfBirth != null ? '${client.gender}, ${client.age} yrs' : client.gender,
                    style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
