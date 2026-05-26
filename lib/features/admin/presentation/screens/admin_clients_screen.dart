import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '../../../contacts/presentation/providers/contacts_providers.dart';
import '../providers/admin_data_provider.dart';
import 'admin_client_detail_screen.dart';

class AdminClientsScreen extends ConsumerStatefulWidget {
  const AdminClientsScreen({super.key});

  @override
  ConsumerState<AdminClientsScreen> createState() => _AdminClientsScreenState();
}

class _AdminClientsScreenState extends ConsumerState<AdminClientsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _counselorFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(adminFilteredClientsProvider);
    final counselorsAsync = ref.watch(allCounselorsProvider);
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
                title: Text('Clients', style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 22)),
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
                        hintText: 'Search by alias code...',
                        hintStyle: TextStyle(color: textSecondary),
                        prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                        filled: true, fillColor: surface,
                        border: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide(color: border)),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    counselorsAsync.when(
                      data: (counselors) => DropdownButtonFormField<String?>(
                        isExpanded: true,
                        value: _counselorFilter,
                        decoration: InputDecoration(
                          hintText: 'All Counselors',
                          hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                          prefixIcon: Icon(Icons.filter_list_rounded, color: textSecondary, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: AppRadius.roundedSm, borderSide: BorderSide(color: border)),
                          enabledBorder: OutlineInputBorder(borderRadius: AppRadius.roundedSm, borderSide: BorderSide(color: border)),
                          filled: true, fillColor: surface,
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text('All Counselors', style: TextStyle(color: textPrimary))),
                          ...counselors.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: TextStyle(color: textPrimary)))),
                        ],
                        onChanged: (v) => setState(() => _counselorFilter = v),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ]),
                ),
              ),
              clientsAsync.when(
                data: (clients) {
                  var filtered = clients;
                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered.where((c) => c.aliasCode.toLowerCase().contains(_searchQuery)).toList();
                  }
                  if (_counselorFilter != null) {
                    filtered = filtered.where((c) => c.counselorIds.contains(_counselorFilter)).toList();
                  }

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('No clients found.', style: TextStyle(color: textSecondary))),
                    );
                  }

                  final sorted = List.from(filtered)
                    ..sort((a, b) {
                      final aDate = a.joinDate ?? a.createdAt;
                      final bDate = b.joinDate ?? b.createdAt;
                      return bDate.compareTo(aDate);
                    });

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = sorted[index];
                        final joinStr = c.joinDate != null
                            ? 'Joined ${c.joinDate!.day}/${c.joinDate!.month}/${c.joinDate!.year}'
                            : 'Added ${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}';
                        final counselors = counselorsAsync.asData?.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => AdminClientDetailScreen(client: c, counselors: counselors),
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
                                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(c.aliasCode, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                                    const SizedBox(height: 2),
                                    Text('${c.gender}${c.dateOfBirth != null ? ', ${c.age} yrs' : ''}', style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                                    const SizedBox(height: 2),
                                    Text(joinStr, style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                                  ]),
                                ),
                                if (c.phone != null)
                                  Icon(Icons.phone_rounded, size: 16, color: textSecondary),
                              ]),
                            ),
                          ),
                        );
                      },
                      childCount: sorted.length,
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
                error: (_, _) => SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Could not load clients.', style: TextStyle(color: textSecondary)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
