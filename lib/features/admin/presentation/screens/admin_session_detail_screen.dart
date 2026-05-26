import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design_system/app_design_system.dart';
import '../../../clients/domain/session.dart';
import '../../../clients/presentation/screens/widgets/session_info_card.dart';
import '../../../clients/presentation/screens/widgets/session_sections.dart';
import '../../../clients/presentation/screens/widgets/session_counselors_section.dart';
import '../../../clients/presentation/screens/widgets/session_location_section.dart';
import '../../../assessment_engine/domain/assessment_session.dart';
import '../../../assessment_engine/domain/scoring_engine.dart';
import '../../../assessment_engine/presentation/assessment_results_screen.dart';
import '../../../assessment_engine/presentation/providers/assessment_session_providers.dart';
import 'admin_assessment_detail_screen.dart';

class AdminSessionDetailScreen extends ConsumerStatefulWidget {
  final Session session;

  const AdminSessionDetailScreen({super.key, required this.session});

  @override
  ConsumerState<AdminSessionDetailScreen> createState() => _AdminSessionDetailScreenState();
}

class _AdminSessionDetailScreenState extends ConsumerState<AdminSessionDetailScreen> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final fontFamily = GoogleFonts.outfit().fontFamily!;
    final assessmentsAsync = ref.watch(
      linkedAssessmentSessionsProvider(widget.session.id),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MaxWidthContainer(
          child: AppBar(
            backgroundColor: bg,
            title: Text(
              widget.session.title.isNotEmpty ? widget.session.title : 'Session Details',
              style: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold, color: textPrimary),
            ),
          ),
        ),
      ),
      body: MaxWidthContainer(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SessionInfoCard(
              fontFamily: fontFamily,
              date: widget.session.date,
              startTime: widget.session.startTime,
              endTime: widget.session.endTime,
              title: widget.session.title,
              clientAlias: widget.session.clientAlias,
              onPickDate: () {},
              onPickStartTime: () {},
              onPickEndTime: () {},
            ),
            const SizedBox(height: AppSpacing.lg),
            SessionStatusSection(
              fontFamily: fontFamily,
              status: widget.session.status,
              onStatusChanged: (_) {},
            ),
            if (widget.session.followUpDate != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SessionFollowUpSection(
                fontFamily: fontFamily,
                followUpDate: widget.session.followUpDate,
                onPickDate: () {},
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SessionCounselorsSection(
              fontFamily: fontFamily,
              counselorIds: widget.session.counselorIds,
            ),
            const SizedBox(height: AppSpacing.lg),
            _AdminAssessmentSection(fontFamily: fontFamily, assessmentsAsync: assessmentsAsync),
            const SizedBox(height: AppSpacing.lg),
            _NotesBlock(fontFamily: fontFamily, notes: widget.session.notes),
            if (widget.session.latitude != null && widget.session.longitude != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SessionLocationSection(
                fontFamily: fontFamily,
                latitude: widget.session.latitude,
                longitude: widget.session.longitude,
                locationTimestamp: widget.session.locationTimestamp,
                mapController: _mapController,
                onRecord: () {},
                onRemove: () {},
                onOpenInMaps: () => launchUrl(
                  Uri.parse('https://www.google.com/maps?q=${widget.session.latitude},${widget.session.longitude}'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotesBlock extends StatelessWidget {
  final String fontFamily;
  final String notes;

  const _NotesBlock({required this.fontFamily, required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: border),
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
          Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: fontFamily, color: textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Text(notes, style: TextStyle(fontSize: 14, color: textSecondary, fontFamily: fontFamily, height: 1.5)),
        ],
      ),
    );
  }
}

class _AdminAssessmentSection extends ConsumerWidget {
  final String fontFamily;
  final AsyncValue<List<AssessmentSession>> assessmentsAsync;

  const _AdminAssessmentSection({
    required this.fontFamily,
    required this.assessmentsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assessment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: fontFamily, color: textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          assessmentsAsync.when(
            data: (assessments) {
              if (assessments.isEmpty) {
                return Text('No assessments linked.', style: TextStyle(color: textSecondary, fontFamily: fontFamily));
              }
              return Column(
                children: assessments.map((a) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (_, __, ___) => AdminAssessmentDetailScreen(assessment: a),
                      transitionsBuilder: (_, __, ___, child) => child,
                    )),
                    borderRadius: AppRadius.roundedMd,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark : AppColors.background,
                        borderRadius: AppRadius.roundedMd,
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat.yMMMd().add_jm().format(a.createdAt),
                            style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                          const SizedBox(height: 4),
                          Text(getTestDisplayName(a.testId),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                          if (a.scores.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            _AdminScoreSummary(scores: a.scores, isDark: isDark),
                          ],
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _AdminScoreSummary extends StatelessWidget {
  final Map<String, ScoreResult> scores;
  final bool isDark;

  const _AdminScoreSummary({required this.scores, required this.isDark});

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

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 6, runSpacing: 4,
      children: scores.entries.map((e) {
        final score = e.value;
        final color = _severityColor(score.severity);
        final label = score.scale == 'general'
            ? ''
            : score.scale == 'suicide_risk'
                ? 'Sui '
                : '${score.scale.substring(0, 3).toUpperCase()} ';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
          child: Text('$label${score.rawScore}/${score.maxScore}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, fontFamily: 'monospace')),
        );
      }).toList(),
    );
  }
}
