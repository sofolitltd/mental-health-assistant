import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '/features/dashboard/presentation/providers/dashboard_providers.dart';
import '../providers/admin_data_provider.dart';
import 'admin_session_detail_screen.dart';

class AdminSessionsScreen extends ConsumerStatefulWidget {
  const AdminSessionsScreen({super.key});

  @override
  ConsumerState<AdminSessionsScreen> createState() => _AdminSessionsScreenState();
}

class _AdminSessionsScreenState extends ConsumerState<AdminSessionsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(adminEffectiveOrgIdProvider);
    final sessionsAsync = ref.watch(allSessionsProvider);
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
                title: Text('Sessions', style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 22)),
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
                        hintText: 'Search by client alias or title...',
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
                      value: _statusFilter,
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
                        DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (v) => setState(() => _statusFilter = v),
                    ),
                  ]),
                ),
              ),
              sessionsAsync.when(
                data: (sessions) {
                  var orgFiltered = orgId == null || orgId.isEmpty
                      ? sessions
                      : sessions.where((s) => s.organizationId == orgId).toList();
                  var filtered = List.from(orgFiltered)
                    ..sort((a, b) => b.date.compareTo(a.date));

                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered.where((s) =>
                      s.clientAlias.toLowerCase().contains(_searchQuery) ||
                      s.title.toLowerCase().contains(_searchQuery)).toList();
                  }
                  if (_statusFilter != null) {
                    filtered = filtered.where((s) => s.status == _statusFilter).toList();
                  }

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('No sessions found.', style: TextStyle(color: textSecondary))),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final s = filtered[index] as dynamic;
                        final statusColor = s.status == 'completed' ? Colors.green
                            : s.status == 'cancelled' ? Colors.red : AppColors.primary;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => AdminSessionDetailScreen(session: s),
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
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: AppRadius.roundedSm,
                                    ),
                                    child: Icon(
                                      s.status == 'completed' ? Icons.check_circle_outline
                                          : s.status == 'cancelled' ? Icons.cancel_outlined
                                          : Icons.schedule_rounded,
                                      color: statusColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(s.title.isNotEmpty ? s.title : 'Session',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                                      const SizedBox(height: 2),
                                      Text('${s.clientAlias} — ${DateFormat.MMMd().add_jm().format(s.date)}',
                                        style: TextStyle(fontSize: 13, color: textSecondary, fontFamily: fontFamily)),
                                      if (s.followUpDate != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text('Follow-up: ${DateFormat.MMMd().format(s.followUpDate!)}',
                                            style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                                        ),
                                    ]),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(s.status[0].toUpperCase() + s.status.substring(1),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor, fontFamily: fontFamily)),
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
                error: (_, _) => SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Could not load sessions.', style: TextStyle(color: textSecondary)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
