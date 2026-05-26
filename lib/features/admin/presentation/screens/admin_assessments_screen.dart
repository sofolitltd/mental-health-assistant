import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '/features/assessment_engine/presentation/assessment_results_screen.dart';
import '/features/dashboard/presentation/providers/dashboard_providers.dart';
import '../providers/admin_data_provider.dart';
import 'admin_assessment_detail_screen.dart';

class AdminAssessmentsScreen extends ConsumerStatefulWidget {
  const AdminAssessmentsScreen({super.key});

  @override
  ConsumerState<AdminAssessmentsScreen> createState() => _AdminAssessmentsScreenState();
}

class _AdminAssessmentsScreenState extends ConsumerState<AdminAssessmentsScreen> {
  String _searchQuery = '';
  String? _reviewedFilter;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(adminEffectiveOrgIdProvider);
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
      body: SafeArea(
        child: MaxWidthContainer(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: Text('Assessments', style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 22)),
                floating: true, snap: true, centerTitle: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: Column(children: [
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search by client alias...',
                        hintStyle: TextStyle(color: textSecondary),
                        prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                        filled: true, fillColor: surface,
                        border: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide(color: border)),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String?>(
                      isExpanded: true,
                      value: _reviewedFilter,
                      decoration: InputDecoration(
                        hintText: 'All Status',
                        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                        prefixIcon: Icon(Icons.filter_list_rounded, color: textSecondary, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(borderRadius: AppRadius.roundedSm, borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.roundedSm, borderSide: BorderSide(color: border)),
                        filled: true, fillColor: surface,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Status')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'reviewed', child: Text('Reviewed')),
                      ],
                      onChanged: (v) => setState(() => _reviewedFilter = v),
                    ),
                  ]),
                ),
              ),
              assessmentsAsync.when(
                data: (assessments) {
                  var orgFiltered = orgId == null || orgId.isEmpty
                      ? assessments
                      : assessments.where((a) => a.organizationId == orgId).toList();
                  var filtered = List.from(orgFiltered)
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered.where((a) => a.clientAlias.toLowerCase().contains(_searchQuery)).toList();
                  }
                  if (_reviewedFilter == 'pending') {
                    filtered = filtered.where((a) => !a.reviewed).toList();
                  } else if (_reviewedFilter == 'reviewed') {
                    filtered = filtered.where((a) => a.reviewed).toList();
                  }

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('No assessments found.', style: TextStyle(color: textSecondary))),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final a = filtered[index] as dynamic;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => AdminAssessmentDetailScreen(assessment: a),
                              transitionsBuilder: (_, __, ___, child) => child,
                            )),
                            borderRadius: AppRadius.roundedMd,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: a.reviewed ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: AppRadius.roundedSm,
                                    ),
                                    child: Icon(a.reviewed ? Icons.check_rounded : Icons.hourglass_empty_rounded,
                                      color: a.reviewed ? Colors.green : Colors.orange, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(a.clientAlias.isNotEmpty ? a.clientAlias : a.clientId,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                                      const SizedBox(height: 2),
                                      Text(getTestDisplayName(a.testId),
                                        style: TextStyle(fontSize: 13, color: textSecondary, fontFamily: fontFamily)),
                                      const SizedBox(height: 2),
                                      Text(DateFormat.yMMMd().add_jm().format(a.createdAt),
                                        style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                                    ]),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: a.reviewed ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(a.reviewed ? 'Reviewed' : 'Pending',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                        color: a.reviewed ? Colors.green : Colors.orange, fontFamily: fontFamily)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
                error: (_, _) => SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Could not load assessments.', style: TextStyle(color: textSecondary)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
