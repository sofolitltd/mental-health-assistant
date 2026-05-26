import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/app_design_system.dart';
import '../../clients/domain/session.dart';
import '../../clients/presentation/providers/client_detail_providers.dart';
import '../data/assessment_session_repository.dart';
import '../domain/assessment_session.dart';
import '../domain/scoring_engine.dart';

String getTestDisplayName(String testId) {
  const names = {
    'dass21_bn': 'DASS-21 (Bangla)',
    'srq20_bn': 'SRQ-20 (Bangla)',
    'cspt_bn': 'C-SSRS (Bangla)',
  };
  return names[testId] ?? testId;
}

class AssessmentResultsScreen extends ConsumerStatefulWidget {
  final AssessmentSession session;
  final String testName;
  final String? returnPath;

  const AssessmentResultsScreen({
    super.key,
    required this.session,
    required this.testName,
    this.returnPath,
  });

  @override
  ConsumerState<AssessmentResultsScreen> createState() =>
      _AssessmentResultsScreenState();
}

class _AssessmentResultsScreenState
    extends ConsumerState<AssessmentResultsScreen> {
  late AssessmentSession _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'normal':
      case 'no risk indicated':
        return Colors.green;
      case 'mild':
      case 'low risk':
        return Colors.amber;
      case 'moderate':
      case 'probable mental distress':
      case 'moderate risk':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      case 'extremely severe':
      case 'high risk':
        return const Color(0xFFB71C1C);
      default:
        return AppColors.textSecondary;
    }
  }

  Color _severityColorFromThreshold(
      SeverityThreshold t, String currentSeverity) {
    if (t.label == currentSeverity) {
      return _severityColor(t.label);
    }
    return _severityColor(t.label).withOpacity(0.35);
  }

  Future<void> _changeSession() async {
    final sessions = await ref
        .read(sessionRepositoryProvider)
        .watchSessionsByClientId(_session.clientId)
        .first;

    if (!context.mounted) return;

    final result = await showDialog<(String?, DateTime)>(
      context: context,
      builder: (ctx) => SessionPickerDialog(
        sessions: sessions,
        currentSessionId: _session.linkedSessionId,
        currentDate: _session.createdAt,
      ),
    );

    if (result != null && context.mounted) {
      final (selectedId, selectedDate) = result;
      _session = AssessmentSession(
        sessionId: _session.sessionId,
        organizationId: _session.organizationId,
        psychologistId: _session.psychologistId,
        clientId: _session.clientId,
        clientAlias: _session.clientAlias,
        testId: _session.testId,
        createdAt: selectedDate,
        rawResponses: _session.rawResponses,
        scores: _session.scores,
        linkedSessionId: selectedId == null || selectedId.isEmpty ? null : selectedId,
      );
      await ref
          .read(assessmentSessionRepositoryProvider)
          .saveSession(_session);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session link updated')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _deleteAssessment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : null,
          title: Text('Delete Assessment',
            style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          content: Text(
            'Are you sure you want to delete this assessment? This action cannot be undone.',
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref
          .read(assessmentSessionRepositoryProvider)
          .deleteSession(_session.sessionId);
      if (context.mounted) {
        context.go(widget.returnPath ?? '/clients/${_session.clientId}/about');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scores = _session.scores.values.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontFamily = GoogleFonts.outfit().fontFamily;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: MaxWidthContainer(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.testName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    Container(
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
                        children: [
                          Text(
                            'Completed ${DateFormat.yMMMd().format(_session.createdAt)}',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Assessment Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...scores.map(
                      (result) => _buildScaleCard(
                        result,
                        _session.testId,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedMd,
                      ),
                    ),
                    onPressed: () => context.go(
                      widget.returnPath ?? '/clients/${_session.clientId}',
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScaleCard(ScoreResult result, String testId, bool isDark) {
    final color = _severityColor(result.severity);
    final thresholds = getSeverityThresholds(testId, result.scale);
    final maxScore = result.maxScore > 0 ? result.maxScore : 1;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                result.scale.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Text(
                  result.severity,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.rawScore}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 9, left: 4),
                child: Text(
                  '/ $maxScore',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: AppRadius.roundedSm,
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  for (final t in thresholds)
                    Expanded(
                      flex: t.max - t.min + 1,
                      child: Container(
                        color: _severityColorFromThreshold(t, result.severity),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...thresholds.map((t) {
            final isCurrent = t.label == result.severity;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? _severityColor(t.label)
                          : _severityColor(t.label).withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent
                            ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${t.min}${t.min != t.max ? ' - ${t.max}' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrent
                          ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (result.interpretation != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: AppRadius.roundedSm,
              ),
              child: Text(
                result.interpretation!,
                style: TextStyle(
                  fontSize: 13,
                  color: color.withOpacity(0.9),
                  height: 1.4,
                ).merge(
                  testId.endsWith('_bn') ? GoogleFonts.tiroBangla() : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SessionPickerDialog extends StatefulWidget {
  final List<Session> sessions;
  final String? currentSessionId;
  final DateTime currentDate;

  const SessionPickerDialog({
    required this.sessions,
    this.currentSessionId,
    required this.currentDate,
  });

  @override
  State<SessionPickerDialog> createState() => SessionPickerDialogState();
}

class SessionPickerDialogState extends State<SessionPickerDialog> {
  String? _selected;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSessionId;
    _selectedDate = widget.currentDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link_rounded, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Link to Session',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: AppRadius.roundedSm,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: border),
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat.yMMMd().format(_selectedDate),
                            style: TextStyle(fontSize: 14, color: textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Link to Session:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButtonFormField<String?>(
                      value: _selected,
                      isExpanded: true,
                      dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                      icon: Icon(Icons.arrow_drop_down_rounded, color: textSecondary),
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.roundedSm,
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.roundedSm,
                          borderSide: BorderSide(color: border),
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Unlinked', style: TextStyle(color: textPrimary, fontSize: 14)),
                        ),
                        ...widget.sessions.map((s) {
                          final label = s.title.isNotEmpty
                              ? s.title
                              : DateFormat.yMMMd().format(s.date);
                          return DropdownMenuItem<String?>(
                            value: s.id,
                            child: Text(label, style: TextStyle(color: textPrimary, fontSize: 14)),
                          );
                        }),
                      ],
                      onChanged: (val) => setState(() => _selected = val),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: textPrimary)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedMd,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, (_selected, _selectedDate)),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }
}
