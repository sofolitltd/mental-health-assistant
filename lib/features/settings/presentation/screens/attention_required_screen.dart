import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '/features/dashboard/presentation/providers/dashboard_providers.dart';

class AttentionRequiredScreen extends ConsumerWidget {
  const AttentionRequiredScreen({super.key});

  bool _isHighSeverity(String severity) {
    switch (severity) {
      case 'High Risk':
      case 'Severe':
      case 'Extremely Severe':
      case 'Moderate Risk':
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsAsync = ref.watch(allAssessmentSessionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MaxWidthContainer(
          child: AppBar(
            backgroundColor: bg,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              onPressed: () => context.go('/settings'),
            ),
            title: Text(
              'Attention Required',
              style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: MaxWidthContainer(
        child: assessmentsAsync.when(
          data: (assessments) {
            final alerts = assessments
                .where((a) => a.scores.values.any((s) => _isHighSeverity(s.severity)))
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (alerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No attention-required items',
                      style: TextStyle(color: textSecondary, fontSize: 16, fontFamily: fontFamily),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final severity = alert.scores.values
                    .where((s) => _isHighSeverity(s.severity))
                    .map((s) => s.severity)
                    .join(', ');

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: alert.reviewed
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Icon(
                          alert.reviewed ? Icons.check_rounded : Icons.warning_amber_rounded,
                          color: alert.reviewed ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.clientAlias.isNotEmpty ? alert.clientAlias : alert.clientId,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: textPrimary,
                                fontFamily: fontFamily,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              severity,
                              style: TextStyle(
                                fontSize: 13,
                                color: alert.reviewed ? Colors.green : Colors.red,
                                fontFamily: fontFamily,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat.yMMMd().add_jm().format(alert.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: alert.reviewed
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          alert.reviewed ? 'Dismissed' : 'Pending',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: alert.reviewed ? Colors.green : Colors.orange,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Unable to load data.\n$err',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
