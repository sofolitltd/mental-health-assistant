import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '../providers/admin_auth_provider.dart';
import '../widgets/change_admin_password_dialog.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                title: Text('Admin Settings', style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 22)),
                floating: true, snap: true, centerTitle: false,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                      child: ref.watch(adminProfileProvider).when(
                        data: (profile) {
                          final role = ref.watch(adminRoleProvider).asData?.value ?? 'admin';
                          final name = profile?['name'] as String? ?? 'Admin';
                          final email = profile?['email'] as String? ?? '';
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  name[0].toUpperCase(),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary, fontFamily: fontFamily),
                                    ),
                                    const SizedBox(height: 2),
                                    if (email.isNotEmpty)
                                      Text(
                                        email,
                                        style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily),
                                      ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        role.toUpperCase(),
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: fontFamily),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary, fontFamily: fontFamily)),
                          const SizedBox(height: AppSpacing.sm),
                          _SettingTile(
                            icon: Icons.lock_outline_rounded,
                            iconColor: AppColors.primary,
                            title: 'Change Password',
                            subtitle: 'Update your admin password',
                            onTap: () => showDialog(context: context, builder: (_) => const ChangeAdminPasswordDialog()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _OrgFilterCard(),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Navigation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary, fontFamily: fontFamily)),
                          const SizedBox(height: AppSpacing.sm),
                          _SettingTile(
                            icon: Icons.arrow_back_rounded,
                            iconColor: AppColors.primary,
                            title: 'Back to App',
                            subtitle: 'Return to the main application',
                            onTap: () => context.go('/settings'),
                          ),
                          const Divider(height: 24),
                          _SettingTile(
                            icon: Icons.logout,
                            iconColor: AppColors.accent,
                            title: 'Admin Logout',
                            subtitle: 'Sign out of admin panel',
                            onTap: () {
                              ref.read(adminAuthProvider.notifier).logout();
                              context.go('/admin/login');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary, fontFamily: fontFamily)),
                          const SizedBox(height: AppSpacing.sm),
                          Text('MH Assistant Admin Panel', style: TextStyle(color: textPrimary, fontFamily: fontFamily)),
                          const SizedBox(height: 4),
                          Text('Manage counselors, clients, sessions, and assessments.', style: TextStyle(color: textSecondary, fontFamily: fontFamily, fontSize: 13)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrgFilterCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: AppRadius.roundedSm),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: textSecondary)),
          ])),
          Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
        ]),
      ),
    );
  }
}
