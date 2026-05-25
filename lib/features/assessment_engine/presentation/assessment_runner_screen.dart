import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design_system/app_design_system.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../data/assessment_repository.dart';
import '../data/assessment_session_repository.dart';
import '../domain/assessment_models.dart';
import '../domain/assessment_session.dart';
import '../domain/scoring_engine.dart';
import 'assessment_notifier.dart';

class AssessmentRunnerScreen extends ConsumerStatefulWidget {
  final String testId;
  final String? clientId;
  final String? sessionId;
  final String? returnPath;
  final String clientAlias;

  const AssessmentRunnerScreen({
    super.key,
    required this.testId,
    this.clientId,
    this.sessionId,
    this.returnPath,
    this.clientAlias = '',
  });

  @override
  ConsumerState<AssessmentRunnerScreen> createState() =>
      _AssessmentRunnerScreenState();
}

class _AssessmentRunnerScreenState
    extends ConsumerState<AssessmentRunnerScreen> {
  late final Future<AssessmentTest> _testFuture;

  @override
  void initState() {
    super.initState();
    _testFuture = ref
        .read(assessmentRepositoryProvider)
        .loadTest(widget.testId);

    // Safely reset the assessment state after the initial build to avoid
    // "modify provider while building" errors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(assessmentProvider.notifier).reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: FutureBuilder<AssessmentTest>(
        future: _testFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading test:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Test not found'));
          }

          final test = snapshot.data!;
          return _AssessmentBody(
            test: test,
            clientId: widget.clientId,
            sessionId: widget.sessionId,
            returnPath: widget.returnPath,
            clientAlias: widget.clientAlias,
          );
        },
      ),
    );
  }
}

class _AssessmentBody extends ConsumerStatefulWidget {
  final AssessmentTest test;
  final String? clientId;
  final String? sessionId;
  final String? returnPath;
  final String clientAlias;

  const _AssessmentBody({required this.test, this.clientId, this.sessionId, this.returnPath, this.clientAlias = ''});

  @override
  ConsumerState<_AssessmentBody> createState() => _AssessmentBodyState();
}

class _AssessmentBodyState extends ConsumerState<_AssessmentBody> {
  bool _isSaving = false;
  final _scrollController = ScrollController();
  // Keyed by question ID so we can look up any question's render context
  // regardless of its current position in the visible list.
  late final Map<int, GlobalKey> _questionKeyMap;

  @override
  void initState() {
    super.initState();
    _questionKeyMap = {
      for (final q in widget.test.questions) q.id: GlobalKey(),
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Returns only the questions that should be shown given current [responses].
  List<TestQuestion> _getVisibleQuestions(Map<int, int> responses) {
    return widget.test.questions.where((q) {
      if (q.showIf == null) return true;
      return responses[q.showIf!.questionId] == q.showIf!.value;
    }).toList();
  }

  void _scrollToNextUnanswered(
    List<TestQuestion> visibleQuestions,
    Map<int, int> responses,
  ) {
    final nextQ = visibleQuestions.firstWhere(
      (q) => !responses.containsKey(q.id),
      orElse: () => visibleQuestions.last,
    );
    final ctx = _questionKeyMap[nextQ.id]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(assessmentProvider);
    final notifier = ref.read(assessmentProvider.notifier);
    final visibleQuestions = _getVisibleQuestions(state.responses);
    final progress = notifier.getProgress(visibleQuestions.length);
    final isComplete = notifier.isComplete(visibleQuestions.length);

    return SafeArea(
      child: Center(
        child: MaxWidthContainer(
          child: Column(
            children: [
              // Header
              Container(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        if (widget.clientId != null) {
                          context.go('/clients/${widget.clientId}/assessments');
                        } else {
                          context.go('/dashboard');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.test.testName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${(progress * visibleQuestions.length).round()} / ${visibleQuestions.length} answered',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isComplete && !_isSaving
                          ? () async {
                              setState(() => _isSaving = true);
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                final engine = ScoringEngineFactory.getEngine(
                                  widget.test.testId,
                                );
                                final results = engine.calculate(
                                  state.responses,
                                  widget.test.questions,
                                );

                                final auth = ref.read(authProvider);
                                final assessmentSession = AssessmentSession(
                                  sessionId: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  psychologistId: auth.uid ?? 'unknown',
                                  clientId: widget.clientId ?? '',
                                  clientAlias: widget.clientAlias,
                                  testId: widget.test.testId,
                                  createdAt: DateTime.now(),
                                  linkedSessionId: widget.sessionId,
                                  rawResponses: Map<int, int>.from(
                                    state.responses,
                                  ),
                                  scores: results,
                                );

                                if (widget.clientId != null) {
                                  await ref
                                      .read(assessmentSessionRepositoryProvider)
                                      .saveSession(assessmentSession);
                                }

                                if (!mounted) return;
                                context.push(
                                  '/assessment/${widget.test.testId}/result',
                                  extra: {
                                    'session': assessmentSession,
                                    'testName': widget.test.testName,
                                    'returnPath': widget.returnPath,
                                  },
                                );
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isSaving = false);
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedMd,
                        ),
                      ),
                      child: const Text('Finish'),
                    ),
                  ],
                ),
              ),

              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                color: AppColors.primary,
                minHeight: 3,
              ),

              // Questions
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: visibleQuestions.length +
                      (widget.test.instruction != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (widget.test.instruction != null && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : Colors.amber.withValues(alpha: 0.1),
                            borderRadius: AppRadius.roundedSm,
                            border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 20, color: Colors.amber.shade700),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  widget.test.instruction!,
                                  style: GoogleFonts.tiroBangla(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final qIndex =
                        widget.test.instruction != null ? index - 1 : index;
                    final question = visibleQuestions[qIndex];
                    final selected = state.responses[question.id];
                    // Display number is position in the *full* question list
                    final displayNumber = widget.test.questions
                            .indexWhere((q) => q.id == question.id) +
                        1;
                    return _QuestionCard(
                      key: _questionKeyMap[question.id],
                      question: question,
                      options: widget.test.options,
                      selectedValue: selected,
                      questionNumber: displayNumber,
                      onChanged: (val) {
                        if (val != null) {
                          notifier.setResponse(question.id, val);
                          // Clear responses for questions whose showIf condition
                          // this answer now violates (e.g. Q2→No clears Q3/Q4/Q5).
                          for (final q in widget.test.questions) {
                            if (q.showIf?.questionId == question.id &&
                                q.showIf?.value != val) {
                              notifier.clearResponse(q.id);
                            }
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            final updatedResponses =
                                ref.read(assessmentProvider).responses;
                            final updatedVisible =
                                _getVisibleQuestions(updatedResponses);
                            _scrollToNextUnanswered(
                                updatedVisible, updatedResponses);
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final TestQuestion question;
  final List<TestOption> options;
  final int? selectedValue;
  final int questionNumber;
  final ValueChanged<int?> onChanged;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.selectedValue,
    required this.questionNumber,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAnswered = selectedValue != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isAnswered
              ? AppColors.primary.withOpacity(0.4)
              : (isDark ? AppColors.borderDark : AppColors.border),
          width: isAnswered ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isAnswered
                        ? AppColors.primary
                        : AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      color: isAnswered ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text,
                    style: GoogleFonts.tiroBangla(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? AppColors.borderDark : AppColors.border),
            const SizedBox(height: 8),
            // Options
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: options.map((opt) {
                final isSel = selectedValue == opt.value;
                return RadioListTile<int>(
                  value: opt.value,
                  groupValue: selectedValue,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt.label,
                      style: GoogleFonts.tiroBangla(
                        fontSize: 14,
                        fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                        color: isSel ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                      ),
                    ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
