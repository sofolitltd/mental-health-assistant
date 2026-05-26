import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../contacts/presentation/providers/contacts_providers.dart';
import '../providers/admin_data_provider.dart';
import '../widgets/create_counselor_dialog.dart';
import '../widgets/edit_counselor_dialog.dart';
import 'admin_counselor_detail_screen.dart';

class AdminCounselorsScreen extends ConsumerStatefulWidget {
  const AdminCounselorsScreen({super.key});

  @override
  ConsumerState<AdminCounselorsScreen> createState() => _AdminCounselorsScreenState();
}

class _AdminCounselorsScreenState extends ConsumerState<AdminCounselorsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(adminEffectiveOrgIdProvider);
    final counselorsAsync = ref.watch(allCounselorsProvider);
    final statsAsync = ref.watch(adminDashboardDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const CreateCounselorDialog(),
          );
          if (created == true && mounted) {
            ref.invalidate(allCounselorsProvider);
          }
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Create Counselor'),
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: Text('Counselors', style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 22)),
                floating: true, snap: true, centerTitle: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or ID...',
                      hintStyle: TextStyle(color: textSecondary),
                      prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                      filled: true,
                      fillColor: surface,
                      border: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide(color: border)),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                  ),
                ),
              ),
              counselorsAsync.when(
                data: (counselors) {
                  var orgFiltered = orgId == null || orgId.isEmpty
                      ? counselors
                      : counselors.where((c) => c.organizationId == orgId).toList();
                  final filtered = _searchQuery.isEmpty
                      ? orgFiltered
                      : orgFiltered.where((c) =>
                          c.name.toLowerCase().contains(_searchQuery) ||
                          c.email.toLowerCase().contains(_searchQuery) ||
                          c.employeeId.toLowerCase().contains(_searchQuery) ||
                          c.designation.toLowerCase().contains(_searchQuery)).toList();

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(_searchQuery.isEmpty ? 'No counselors found.' : 'No matching counselors.', style: TextStyle(color: textSecondary))),
                    );
                  }

                  final clientCountMap = statsAsync.value?.counselorClientCount ?? {};

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = filtered[index];
                        final clientCount = clientCountMap[c.id] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => AdminCounselorDetailScreen(counselor: c, clientCount: clientCount),
                              transitionsBuilder: (_, __, ___, child) => child,
                            )),
                            borderRadius: AppRadius.roundedMd,
                            child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                            child: Row(children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(c.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                                  const SizedBox(height: 2),
                                  Text('${c.designation} | ${c.employeeId}', style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                                  const SizedBox(height: 2),
                                  Text(c.email, style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                                ]),
                              ),
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Text('$clientCount clients', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary, fontFamily: fontFamily)),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final updated = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => EditCounselorDialog(counselor: c),
                                    );
                                    if (updated == true && mounted) {
                                      ref.invalidate(allCounselorsProvider);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Counselor'),
                                        content: Text('Delete ${c.name}? This removes their Firebase Auth account and all data.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
                                        ],
                                      ),
                                    );
                                    if (confirmed != true || !mounted) return;
                                    try {
                                      await ref.read(authRepositoryProvider).adminDeleteCounselor(c.id);
                                      if (mounted) {
                                        ref.invalidate(allCounselorsProvider);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text('${c.name} deleted.'),
                                          backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,
                                        ));
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(e.toString().replaceFirst('Exception: ', '')),
                                          backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
                                        ));
                                      }
                                    }
                                  },
                                ),
                              ]),
                            ]),
                          ),
                        ),
                      );
                      },
                      childCount: filtered.length,
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
                error: (_, _) => SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Could not load counselors.', style: TextStyle(color: textSecondary)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
