import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '../providers/admin_data_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: MaxWidthContainer(
          child: statsAsync.when(
            data: (stats) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  title: Text('Admin Dashboard', style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 22)),
                  floating: true, snap: true, centerTitle: false,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 600 ? 4 : 2;
                          final spacing = AppSpacing.sm;
                          final totalSpacing = spacing * (columns - 1);
                          final childWidth = (constraints.maxWidth - totalSpacing) / columns;
                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              SizedBox(width: childWidth, child: _StatCard(title: 'Counselors', value: '${stats.totalCounselors}', icon: Icons.badge_rounded, color: Colors.blue)),
                              SizedBox(width: childWidth, child: _StatCard(title: 'Clients', value: '${stats.totalClients}', icon: Icons.people_rounded, color: Colors.green)),
                              SizedBox(width: childWidth, child: _StatCard(title: 'Sessions', value: '${stats.totalSessions}', icon: Icons.calendar_month_rounded, color: AppColors.primary)),
                              SizedBox(width: childWidth, child: _StatCard(title: 'Assessments', value: '${stats.totalAssessments}', icon: Icons.assignment_rounded, color: Colors.orange)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('This Week', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary, fontFamily: fontFamily)),
                            const SizedBox(height: AppSpacing.sm),
                            Row(children: [
                              _MetricChip(label: '${stats.weekSessions} sessions', color: AppColors.primary),
                              const SizedBox(width: 8),
                              _MetricChip(label: '${stats.weekAssessments} assessments', color: Colors.orange),
                            ]),
                            const SizedBox(height: AppSpacing.md),
                            Text('This Month', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary, fontFamily: fontFamily)),
                            const SizedBox(height: AppSpacing.sm),
                            Row(children: [
                              _MetricChip(label: '${stats.monthSessions} sessions', color: AppColors.primary),
                              const SizedBox(width: 8),
                              _MetricChip(label: '${stats.monthAssessments} assessments', color: Colors.orange),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (stats.unreviewedHighRisk.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: AppRadius.roundedMd,
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text('Alert: ${stats.unreviewedHighRisk.length} high-risk assessments not reviewed',
                                  style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: fontFamily)),
                              ]),
                              const SizedBox(height: AppSpacing.sm),
                              ...stats.unreviewedHighRisk.take(5).map((a) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text('${a.clientAlias} — ${a.testId}', style: TextStyle(fontSize: 13, color: Colors.red.shade800, fontFamily: fontFamily)),
                                ]),
                              )),
                            ],
                          ),
                        ),
                      if (stats.unreviewedHighRisk.isNotEmpty) const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.history_rounded, color: textSecondary, size: 20),
                              const SizedBox(width: 8),
                              Text('Recent Clients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary, fontFamily: fontFamily)),
                            ]),
                            const Divider(),
                            ...stats.recentClients.map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: AppRadius.roundedSm),
                                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(c.aliasCode, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary, fontFamily: fontFamily))),
                                Text(c.gender, style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                              ]),
                            )),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text('Error: $err', style: TextStyle(color: textSecondary)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.roundedSm),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          Text(title, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        ])),
      ]),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MetricChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
