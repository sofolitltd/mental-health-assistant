import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../domain/session.dart';
import '../../../assessment_engine/data/assessment_session_repository.dart';
import '../../../assessment_engine/domain/assessment_session.dart';
import '../../../assessment_engine/domain/scoring_engine.dart';
import '../../../assessment_engine/presentation/assessment_results_screen.dart';
import '../../../assessment_engine/presentation/providers/assessment_session_providers.dart';
import '../providers/client_detail_providers.dart';

class AssessmentsTab extends ConsumerWidget {
  final String clientId;
  final String clientAlias;

  const AssessmentsTab({
    super.key,
    required this.clientId,
    required this.clientAlias,
  });

  static Color _severityColor(String severity) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsAsync = ref.watch(
      clientAssessmentSessionsProvider(clientId),
    );
    final sessionsAsync = ref.watch(clientSessionsProvider(clientId));

    return assessmentsAsync.when(
      data: (assessments) {
        final sessions = sessionsAsync.value ?? <Session>[];
        final sessionMap = <String, Session>{for (final s in sessions) s.id: s};
        if (assessments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'No past assessments yet.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: assessments.length,
          itemBuilder: (context, index) {
            final assessment = assessments[index];
            final _isDark = Theme.of(context).brightness == Brightness.dark;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InkWell(
                onTap: () {
                  context.push(
                    '/assessment/${assessment.testId}/result',
                    extra: {
                      'session': assessment,
                      'testName': getTestDisplayName(assessment.testId),
                    },
                  );
                },
                borderRadius: AppRadius.roundedMd,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(color: _isDark ? AppColors.borderDark : AppColors.border),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Text(
                                    DateFormat.yMMMd().format(assessment.createdAt),
                                    style: TextStyle(
                                      color: _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _SessionLink(
                                    linkedSessionId: assessment.linkedSessionId,
                                    sessionMap: sessionMap,
                                    isDark: _isDark,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                 getTestDisplayName(assessment.testId),
                                 style: TextStyle(
                                   fontWeight: FontWeight.bold,
                                   fontSize: 15,
                                   color: _isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                 ),
                               ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      spacing: 4,
                      children: [
                        Expanded(
                          child: _ScoreSummary(scores: assessment.scores),
                        ),
                        _CardActionButton(
                          icon: Icons.edit,
                          onTap: () async {
                            final sessions = await ref
                                .read(sessionRepositoryProvider)
                                .watchSessionsByClientId(clientId)
                                .first;
                            if (!context.mounted) return;
                            final result = await showDialog<(String?, DateTime)>(
                              context: context,
                              builder: (ctx) => SessionPickerDialog(
                                sessions: sessions,
                                currentSessionId: assessment.linkedSessionId,
                                currentDate: assessment.createdAt,
                              ),
                            );
                            if (result != null && context.mounted) {
                              final (selectedId, selectedDate) = result;
                              final updated = AssessmentSession(
                                sessionId: assessment.sessionId,
                                psychologistId: assessment.psychologistId,
                                clientId: assessment.clientId,
                                clientAlias: assessment.clientAlias,
                                testId: assessment.testId,
                                createdAt: selectedDate,
                                rawResponses: assessment.rawResponses,
                                scores: assessment.scores,
                                linkedSessionId: selectedId == null || selectedId.isEmpty ? null : selectedId,
                              );
                              await ref
                                  .read(assessmentSessionRepositoryProvider)
                                  .saveSession(updated);
                              ref.invalidate(clientAssessmentSessionsProvider(clientId));
                            }
                          },
                        ),
                        const SizedBox(width: 2),
                        _CardActionButton(
                          icon: Icons.delete_outline_rounded,
                          color: Colors.red,
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) {
                                final dk = Theme.of(ctx).brightness == Brightness.dark;
                                return AlertDialog(
                                  backgroundColor: dk ? AppColors.surfaceDark : null,
                                  title: Text('Delete Assessment',
                                    style: TextStyle(color: dk ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                  content: Text('Are you sure?',
                                    style: TextStyle(color: dk ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmed == true && context.mounted) {
                              await ref
                                  .read(assessmentSessionRepositoryProvider)
                                  .deleteSession(assessment.sessionId);
                              ref.invalidate(clientAssessmentSessionsProvider(clientId));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _SessionLink extends StatelessWidget {
  final String? linkedSessionId;
  final Map<String, Session> sessionMap;
  final bool isDark;

  const _SessionLink({
    required this.linkedSessionId,
    required this.sessionMap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final session = linkedSessionId != null ? sessionMap[linkedSessionId] : null;
    final hasSession = session != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: hasSession
            ? AppColors.primary.withOpacity(0.1)
            : (isDark ? Colors.grey.withOpacity(0.15) : Colors.grey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        hasSession ? session!.title : 'Unlinked',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: hasSession ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _CardActionButton({
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: c),
      ),
    );
  }
}

class _ScoreSummary extends StatelessWidget {
  final Map<String, ScoreResult> scores;

  const _ScoreSummary({required this.scores});

  @override
  Widget build(BuildContext context) {
    final entries = scores.entries.toList();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: entries.map((e) {
        final score = e.value;
        final color = AssessmentsTab._severityColor(score.severity);

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
