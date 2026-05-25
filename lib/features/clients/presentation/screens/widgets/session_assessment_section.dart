import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../../../assessment_engine/domain/assessment_session.dart';
import '../../../../assessment_engine/domain/scoring_engine.dart';


String getTestDisplayName(String testId) {
  const names = {
    'dass21_bn': 'DASS-21 (Bangla)',
    'srq20_bn': 'SRQ-20 (Bangla)',
    'cspt_bn': 'C-SSRS (Bangla)',
  };
  return names[testId] ?? testId;
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

class ScoreSummary extends StatelessWidget {
  final Map<String, ScoreResult> scores;
  final bool isDark;

  const ScoreSummary({super.key, required this.scores, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final entries = scores.entries.toList();
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 6,
      runSpacing: 4,
      children: entries.map((e) {
        final score = e.value;
        final color = _severityColor(score.severity);

        final label = score.scale == 'general'
            ? ''
            : score.scale == 'suicide_risk'
                ? 'Sui '
                : '${score.scale.substring(0, 3).toUpperCase()} ';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$label${score.rawScore}/${score.maxScore}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SessionAssessmentSection extends ConsumerWidget {
  final String fontFamily;
  final AsyncValue<List<AssessmentSession>> assessmentsAsync;
  final VoidCallback onStartAssessment;

  const SessionAssessmentSection({
    super.key,
    required this.fontFamily,
    required this.assessmentsAsync,
    required this.onStartAssessment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assessmentsAsync = this.assessmentsAsync;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assessment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Start New Assessment'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedSm,
                ),
              ),
              onPressed: onStartAssessment,
            ),
          ),
          assessmentsAsync.when(
            data: (assessments) {
              if (assessments.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: isDark ? AppColors.borderDark : AppColors.border),
                    const SizedBox(height: AppSpacing.sm),
                    ...assessments.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: InkWell(
                        onTap: () {
                          context.push(
                            '/assessment/${a.testId}/result',
                            extra: {
                              'session': a,
                              'testName': getTestDisplayName(a.testId),
                            },
                          );
                        },
                        borderRadius: AppRadius.roundedMd,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surface,
                            borderRadius: AppRadius.roundedMd,
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cardShadow,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMd().format(a.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                getTestDisplayName(a.testId),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                              ),
                              if (a.scores.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                ScoreSummary(scores: a.scores, isDark: isDark),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: CircularProgressIndicator(),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text('Error: $err', style: TextStyle(color: AppColors.accent)),
            ),
          ),
        ],
      ),
    );
  }
}
