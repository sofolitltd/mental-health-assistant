import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../contacts/domain/counselor.dart';
import '../../../contacts/presentation/providers/contacts_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../presentation/providers/admin_data_provider.dart';
import '../widgets/edit_counselor_dialog.dart';
import 'admin_client_detail_screen.dart';
import 'admin_session_detail_screen.dart';

class AdminCounselorDetailScreen extends ConsumerStatefulWidget {
  final Counselor counselor;
  final int clientCount;

  const AdminCounselorDetailScreen({
    super.key,
    required this.counselor,
    required this.clientCount,
  });

  @override
  ConsumerState<AdminCounselorDetailScreen> createState() => _AdminCounselorDetailScreenState();
}

class _AdminCounselorDetailScreenState extends ConsumerState<AdminCounselorDetailScreen>
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

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: MaxWidthContainer(
          child: Column(
            children: [
              AppBar(
                backgroundColor: bg,
                title: Text(widget.counselor.name, style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: () async {
                      final updated = await showDialog<bool>(
                        context: context,
                        builder: (_) => EditCounselorDialog(counselor: widget.counselor),
                      );
                      if (updated == true && mounted) {
                        ref.invalidate(allCounselorsProvider);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Counselor'),
                          content: Text('Delete ${widget.counselor.name}? This removes their Firebase Auth account and all data.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed != true || !mounted) return;
                      try {
                        await ref.read(authRepositoryProvider).adminDeleteCounselor(widget.counselor.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${widget.counselor.name} deleted.'),
                            backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,
                          ));
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(e.toString().replaceFirst('Exception:', '')),
                            backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
                          ));
                        }
                      }
                    },
                  ),
                ],
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
                    Tab(text: 'Clients'),
                    Tab(text: 'Sessions'),
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
            counselor: widget.counselor,
            clientCount: widget.clientCount,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            surface: surface,
            border: border,
            fontFamily: fontFamily,
          ),
          _ClientsTab(counselorId: widget.counselor.id),
          _SessionsTab(counselorId: widget.counselor.id),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final Counselor counselor;
  final int clientCount;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;
  final String fontFamily;

  const _AboutTab({
    required this.counselor,
    required this.clientCount,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                counselor.name.isNotEmpty ? counselor.name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 32, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(label: 'Name', value: counselor.name, textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                _Row(label: 'Email', value: counselor.email, textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                _Row(label: 'Phone', value: counselor.phone, textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                _Row(label: 'Designation', value: counselor.designation, textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                _Row(label: 'Employee ID', value: counselor.employeeId, textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
                _Row(label: 'Clients', value: '$clientCount', textPrimary: textPrimary, textSecondary: textSecondary, fontFamily: fontFamily),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientsTab extends ConsumerWidget {
  final String counselorId;

  const _ClientsTab({required this.counselorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(adminFilteredClientsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';

    return clientsAsync.when(
      data: (clients) {
        final filtered = clients.where((c) => c.counselorIds.contains(counselorId)).toList();
        if (filtered.isEmpty) {
          return Center(child: Text('No clients assigned.', style: TextStyle(color: textSecondary)));
        }
        return MaxWidthContainer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final c = filtered[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => AdminClientDetailScreen(client: c),
                    transitionsBuilder: (_, __, ___, child) => child,
                  )),
                  borderRadius: AppRadius.roundedMd,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: AppRadius.roundedSm),
                        child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.aliasCode, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                        Text('${c.gender}${c.dateOfBirth != null ? ' · ${c.age} yrs' : ''}',
                          style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                      ])),
                    ]),
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

class _SessionsTab extends ConsumerWidget {
  final String counselorId;

  const _SessionsTab({required this.counselorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';

    return sessionsAsync.when(
      data: (sessions) {
        final filtered = sessions.where((s) => s.counselorIds.contains(counselorId)).toList();
        if (filtered.isEmpty) {
          return Center(child: Text('No sessions found.', style: TextStyle(color: textSecondary)));
        }
        return MaxWidthContainer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final s = filtered[index];
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
                        const SizedBox(height: 2),
                        Text(s.clientAlias,
                          style: TextStyle(fontSize: 13, color: textSecondary, fontFamily: fontFamily)),
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
