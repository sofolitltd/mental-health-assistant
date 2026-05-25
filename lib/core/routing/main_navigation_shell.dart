import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../design_system/app_design_system.dart';

class MainNavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = navigationShell.currentIndex;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.md;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: bg,
        body: Row(
          children: [
            _DesktopSidebar(
              activeIndex: activeIndex,
              onNavigate: (index) => navigationShell.goBranch(index),
              ref: ref,
            ),
            VerticalDivider(width: 1, thickness: 1, color: border),
            Expanded(child: navigationShell),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: bg,
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: border, width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: activeIndex,
            onTap: (index) => navigationShell.goBranch(index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Clients',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contact_phone_outlined),
                activeIcon: Icon(Icons.contact_phone_rounded),
                label: 'Contacts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onNavigate;
  final WidgetRef ref;

  const _DesktopSidebar({
    required this.activeIndex,
    required this.onNavigate,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      width: 260,
      color: surface,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MH Assistant',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isActive: activeIndex == 0,
                  onTap: () => onNavigate(0),
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people_rounded,
                  label: 'Clients',
                  isActive: activeIndex == 1,
                  onTap: () => onNavigate(1),
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  icon: Icons.contact_phone_outlined,
                  activeIcon: Icons.contact_phone_rounded,
                  label: 'Contacts',
                  isActive: activeIndex == 2,
                  onTap: () => onNavigate(2),
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  isActive: activeIndex == 3,
                  onTap: () => onNavigate(3),
                ),
              ],
            ),
          ),

          Divider(color: border, height: 24),

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      authState.name ?? 'Dr. Rahman',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      authState.email ?? 'Psychologist',
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.accent,
                  size: 20,
                ),
                tooltip: 'Log Out',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'Sign Out',
                        style: TextStyle(color: textPrimary),
                      ),
                      content: Text(
                        'Are you sure you want to log out of your session?',
                        style: TextStyle(color: textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref.read(authProvider.notifier).logout();
                            if (ctx.mounted) {
                              GoRouter.of(ctx).go('/login');
                            }
                          },
                          child: const Text('Sign Out', style: TextStyle(color: AppColors.accent)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedSm,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: AppRadius.roundedSm,
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : inactiveColor,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.primary : inactiveColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
