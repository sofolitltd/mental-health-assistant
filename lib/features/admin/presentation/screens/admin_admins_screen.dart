import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/data/repositories/auth_repository.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '../widgets/admin_form_dialog.dart';

class AdminAdminsScreen extends ConsumerWidget {
  const AdminAdminsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';
    final adminsAsync = ref.watch(_adminListProvider);
    final orgs = ref.watch(organizationsProvider).asData?.value ?? [];
    final orgMap = {for (final o in orgs) o.id: o.name};

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const AdminFormDialog(),
          );
          if (created == true) ref.invalidate(_adminListProvider);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Admin'),
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: Text('Admins', style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 22)),
                floating: true, snap: true, centerTitle: false,
              ),
              adminsAsync.when(
                data: (admins) {
                  if (admins.isEmpty) {
                    return SliverFillRemaining(hasScrollBody: false, child: Center(
                      child: Text('No admins.', style: TextStyle(color: textSecondary)),
                    ));
                  }

                  final grouped = <String?, List<Map<String, dynamic>>>{};
                  for (final admin in admins) {
                    final oid = admin['organizationId'] as String?;
                    grouped.putIfAbsent(oid ?? '__unset__', () => []).add(admin);
                  }
                  final groupKeys = grouped.keys.toList()..sort((a, b) {
                    if (a == '__unset__') return -1;
                    if (b == '__unset__') return 1;
                    return (orgMap[a] ?? a ?? '').compareTo(orgMap[b] ?? b ?? '');
                  });

                  final tiles = <Widget>[];
                  for (final key in groupKeys) {
                    final members = grouped[key]!;
                    final isUnset = key == '__unset__';
                    final headerName = isUnset ? 'Unassigned' : (orgMap[key] ?? key ?? '');

                    tiles.add(Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 4),
                      child: Row(children: [
                        Text(headerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textSecondary, fontFamily: fontFamily, letterSpacing: 0.5)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text('${members.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ]),
                    ));

                    for (final admin in members) {
                      final name = admin['name'] as String? ?? '?';
                      final email = admin['email'] as String? ?? '';
                      final role = admin['role'] as String? ?? 'admin';
                      final isSuper = role == 'super_admin';
                      tiles.add(Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                          child: Row(children: [
                            CircleAvatar(
                              backgroundColor: isSuper ? AppColors.accent.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                              child: Text(name[0].toUpperCase(), style: TextStyle(color: isSuper ? AppColors.accent : AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                              const SizedBox(height: 2),
                              Text(email, style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSuper ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: isSuper
                                  ? const Text('SUPER ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent))
                                  : const SizedBox.shrink(),
                              ),
                            ])),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                              onPressed: () async {
                                final updated = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AdminFormDialog(admin: admin),
                                );
                                if (updated == true) ref.invalidate(_adminListProvider);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                              onPressed: () async {
                                final id = admin['id'] as String? ?? '';
                                if (id.isEmpty) return;
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Admin'),
                                    content: Text('Delete "$name"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirmed != true || !context.mounted) return;
                                try {
                                  await ref.read(authRepositoryProvider).deleteAdmin(id);
                                  if (context.mounted) {
                                    ref.invalidate(_adminListProvider);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('$name deleted.'),
                                      backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,
                                    ));
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(e.toString().replaceFirst('Exception: ', '')),
                                      backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
                                    ));
                                  }
                                }
                              },
                            ),
                          ]),
                        ),
                      ));
                    }
                  }

                  return SliverList(delegate: SliverChildListDelegate(tiles));
                },
                loading: () => const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
                error: (_, _) => SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Could not load admins.', style: TextStyle(color: textSecondary)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _adminListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    return await ref.read(authRepositoryProvider).getAdmins();
  } catch (_) {
    return [];
  }
});
