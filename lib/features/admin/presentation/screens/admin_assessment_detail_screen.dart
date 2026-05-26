import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '/features/assessment_engine/domain/assessment_session.dart';
import '/features/assessment_engine/presentation/assessment_results_screen.dart';

class AdminAssessmentDetailScreen extends StatelessWidget {
  final AssessmentSession assessment;

  const AdminAssessmentDetailScreen({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
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
            title: Text(getTestDisplayName(assessment.testId), style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold)),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => AssessmentResultsScreen(
                    session: assessment,
                    testName: getTestDisplayName(assessment.testId),
                  ),
                  transitionsBuilder: (_, __, ___, child) => child,
                )),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Full Results'),
              ),
            ],
          ),
        ),
      ),
      body: MaxWidthContainer(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row(label: 'Client', value: assessment.clientAlias.isNotEmpty ? assessment.clientAlias : assessment.clientId,
                    textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                  _Row(label: 'Test', value: getTestDisplayName(assessment.testId),
                    textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                  _Row(label: 'Date', value: DateFormat.yMMMd().add_jm().format(assessment.createdAt),
                    textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: assessment.reviewed ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        assessment.reviewed ? 'Reviewed' : 'Pending',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: assessment.reviewed ? Colors.green : Colors.orange, fontFamily: fontFamily),
                      ),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Scores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                  const SizedBox(height: AppSpacing.sm),
                  ...assessment.scores.entries.map((e) {
                    final score = e.value;
                    final severityColor = _severityColor(score.severity);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.08),
                        borderRadius: AppRadius.roundedSm,
                        border: Border.all(color: severityColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(score.scale.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textPrimary, fontFamily: fontFamily)),
                            const SizedBox(height: 2),
                            Text('${score.rawScore}/${score.maxScore} — ${score.severity}',
                              style: TextStyle(fontSize: 12, color: severityColor, fontFamily: fontFamily, fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      ]),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'normal':
      case 'no risk indicated':
        return const Color(0xFF4CAF50);
      case 'mild':
      case 'low risk':
        return const Color(0xFF8BC34A);
      case 'moderate':
      case 'moderate risk':
        return const Color(0xFFFFC107);
      case 'severe':
      case 'high risk':
        return const Color(0xFFFF9800);
      case 'extremely severe':
        return const Color(0xFFF44336);
      case 'probable mental distress':
        return const Color(0xFFFF5722);
      default:
        return AppColors.textSecondary;
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  final String fontFamily;
  const _Row({required this.label, required this.value, required this.textPrimary, required this.textSecondary, required this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(label, style: TextStyle(color: textSecondary, fontSize: 13, fontFamily: fontFamily))),
        Expanded(child: Text(value, style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: fontFamily))),
      ]),
    );
  }
}
