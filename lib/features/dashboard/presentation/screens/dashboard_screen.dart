import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '/core/logger/app_logger.dart';
import '../../../assessment_engine/data/assessment_session_repository.dart';
import '../../../clients/domain/session.dart';
import '../providers/dashboard_providers.dart';
import 'widgets/high_risk_banner.dart';
import 'widgets/quick_stats.dart';
import 'widgets/recent_clients.dart';
import 'widgets/today_schedule.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  ScheduleRange _scheduleRange = ScheduleRange.today;

  List<Session> _filteredSessions(List<Session> sessions) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    DateTime start;
    DateTime end;
    switch (_scheduleRange) {
      case ScheduleRange.today:
        start = todayStart;
        end = todayStart.add(const Duration(days: 1));
      case ScheduleRange.week:
        start = todayStart.subtract(Duration(days: todayStart.weekday - 1));
        end = start.add(const Duration(days: 7));
      case ScheduleRange.month:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
    }

    return sessions
        .where((s) => !s.date.isBefore(start) && s.date.isBefore(end) && s.status != 'cancelled')
        .toList()
      ..sort((a, b) => _scheduleRange == ScheduleRange.today
          ? a.date.compareTo(b.date)
          : b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
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
                        HighRiskBanner(
                          alerts: data.highRiskAlerts,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          fontFamily: fontFamily,
                          onDismiss: (sessionId) async {
                            try {
                              await ref.read(assessmentSessionRepositoryProvider).markAsReviewed(sessionId);
                              ref.invalidate(allAssessmentSessionsProvider);
                              ref.invalidate(dashboardDataProvider);
                            } catch (e, stack) {
                              AppLogger.error('Failed to dismiss alert', {'sessionId': sessionId}, e, stack);
                            }
                          },
                        ),
                      QuickStats(
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
                      LayoutBuilder(builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= AppBreakpoints.lg;
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TodaySchedule(
                                  sessions: _filteredSessions(data.sessions),
                                  range: _scheduleRange,
                                  onRangeChanged: (r) => setState(() => _scheduleRange = r),
                                  isDark: isDark,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  border: border,
                                  surface: surface,
                                  fontFamily: fontFamily,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: RecentClients(
                                  clients: data.recentClients,
                                  isDark: isDark,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  border: border,
                                  surface: surface,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            TodaySchedule(
                              sessions: _filteredSessions(data.sessions),
                              range: _scheduleRange,
                              onRangeChanged: (r) => setState(() => _scheduleRange = r),
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              border: border,
                              surface: surface,
                              fontFamily: fontFamily,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            RecentClients(
                              clients: data.recentClients,
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              border: border,
                              surface: surface,
                              fontFamily: fontFamily,
                            ),
                          ],
                        );
                      }),
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
