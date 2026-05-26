import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../../clients/domain/models/client.dart';
import '../../../clients/domain/session.dart';
import '../../../clients/presentation/providers/client_detail_providers.dart';
import '../../../contacts/domain/counselor.dart';
import '../../../assessment_engine/domain/assessment_session.dart';
import '../../../assessment_engine/presentation/assessment_results_screen.dart';
import '../../../assessment_engine/presentation/providers/assessment_session_providers.dart';
import 'admin_session_detail_screen.dart';
import 'admin_assessment_detail_screen.dart';

class AdminClientDetailScreen extends ConsumerStatefulWidget {
  final Client client;
  final List<Counselor>? counselors;

  const AdminClientDetailScreen({
    super.key,
    required this.client,
    this.counselors,
  });

  @override
  ConsumerState<AdminClientDetailScreen> createState() => _AdminClientDetailScreenState();
}

class _AdminClientDetailScreenState extends ConsumerState<AdminClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';

    final assignedCounselors = widget.counselors != null
        ? widget.client.counselorIds.map((id) => widget.counselors!.where((c) => c.id == id).firstOrNull).whereType<Counselor>().toList()
        : <Counselor>[];

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: MaxWidthContainer(
          child: Column(
            children: [
              AppBar(
                backgroundColor: bg,
                title: Text(widget.client.aliasCode, style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: border)),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: textSecondary,
                  labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: fontFamily),
                  unselectedLabelStyle: TextStyle(fontSize: 14, fontFamily: fontFamily),
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Sessions'),
                    Tab(text: 'Assessments'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AboutTab(
            client: widget.client,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            surface: surface,
            border: border,
            fontFamily: fontFamily,
            assignedCounselors: assignedCounselors,
          ),
          _SessionsTab(clientId: widget.client.id),
          _AssessmentsTab(clientId: widget.client.id),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final Client client;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;
  final String fontFamily;
  final List<Counselor> assignedCounselors;

  const _AboutTab({
    required this.client,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
    required this.fontFamily,
    required this.assignedCounselors,
  });

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(label: 'Alias Code', value: client.aliasCode, textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                _Row(label: 'Gender', value: client.gender, textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                if (client.dateOfBirth != null)
                  _Row(label: 'Age', value: '${client.age} yrs', textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                _Row(label: 'Created', value: DateFormat.yMMMd().add_jm().format(client.createdAt), textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                if (client.joinDate != null)
                  _Row(label: 'Joined', value: DateFormat.yMMMd().format(client.joinDate!), textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                if (client.phone != null)
                  _Row(label: 'Phone', value: client.phone!, textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                const SizedBox(height: AppSpacing.sm),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Text('Assigned Counselors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                const SizedBox(height: AppSpacing.sm),
                if (assignedCounselors.isEmpty)
                  Text('None assigned', style: TextStyle(color: textSecondary, fontFamily: fontFamily))
                else
                  ...assignedCounselors.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(c.name[0].toUpperCase(), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 12),
                      Expanded(child: Text(c.name, style: TextStyle(color: textPrimary, fontFamily: fontFamily))),
                    ]),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsTab extends ConsumerWidget {
  final String clientId;

  const _SessionsTab({required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(clientSessionsProvider(clientId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Center(child: Text('No sessions yet', style: TextStyle(color: textSecondary)));
        }
        return MaxWidthContainer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => AdminSessionDetailScreen(session: s),
                    transitionsBuilder: (_, __, ___, child) => child,
                  )),
                  borderRadius: AppRadius.roundedMd,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(DateFormat.yMMMd().format(s.date),
                            style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: s.status == 'completed' ? Colors.green.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(s.status[0].toUpperCase() + s.status.substring(1),
                              style: TextStyle(fontSize: 10, color: s.status == 'completed' ? Colors.green : AppColors.primary, fontFamily: fontFamily)),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text(s.title.isNotEmpty ? s.title : 'Session',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                        if (s.notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(s.notes, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _AssessmentsTab extends ConsumerWidget {
  final String clientId;

  const _AssessmentsTab({required this.clientId});

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
    final assessmentsAsync = ref.watch(clientAssessmentSessionsProvider(clientId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';

    return assessmentsAsync.when(
      data: (assessments) {
        final sorted = List<AssessmentSession>.from(assessments)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (sorted.isEmpty) {
          return Center(child: Text('No past assessments yet.', style: TextStyle(color: textSecondary)));
        }
        return MaxWidthContainer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final a = sorted[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => AdminAssessmentDetailScreen(assessment: a),
                    transitionsBuilder: (_, __, ___, child) => child,
                  )),
                  borderRadius: AppRadius.roundedMd,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat.yMMMd().add_jm().format(a.createdAt),
                          style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                        const SizedBox(height: 4),
                        Text(getTestDisplayName(a.testId),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(spacing: 6, runSpacing: 4,
                          children: a.scores.entries.map((e) {
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
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, fontFamily: fontFamily)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
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
