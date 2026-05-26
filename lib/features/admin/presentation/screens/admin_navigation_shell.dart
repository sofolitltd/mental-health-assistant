import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '../providers/admin_auth_provider.dart';

const _navItems = [
  _NavItemData(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard', branchIndex: 0),
  _NavItemData(icon: Icons.badge_outlined, activeIcon: Icons.badge_rounded, label: 'Counselors', branchIndex: 1),
  _NavItemData(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'Clients', branchIndex: 2),
  _NavItemData(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Assessments', branchIndex: 3),
  _NavItemData(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Sessions', branchIndex: 4),
  _NavItemData(icon: Icons.admin_panel_settings_outlined, activeIcon: Icons.admin_panel_settings_rounded, label: 'Admins', branchIndex: 5),
  _NavItemData(icon: Icons.business_outlined, activeIcon: Icons.business_rounded, label: 'Organizations', branchIndex: 6),
  _NavItemData(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings', branchIndex: 7),
];

class AdminNavigationShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AdminNavigationShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AdminNavigationShell> createState() => _AdminNavigationShellState();
}

class _AdminNavigationShellState extends ConsumerState<AdminNavigationShell> {
  @override
  void initState() {
    super.initState();
    _redirectIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirectIfNeeded();
  }

  void _redirectIfNeeded() {
    final role = ref.read(adminRoleProvider).asData?.value ?? 'admin';
    final currentBranch = widget.navigationShell.currentIndex;
    if (role == 'super_admin' && currentBranch < 5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.navigationShell.goBranch(5);
      });
    } else if (role == 'admin' && currentBranch >= 5 && currentBranch <= 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.navigationShell.goBranch(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(adminRoleProvider).asData?.value ?? 'admin';
    final isSuperAdmin = role == 'super_admin';
    final displayItems = isSuperAdmin
        ? _navItems.where((item) => item.branchIndex >= 5).toList()
        : _navItems.where((item) => item.branchIndex <= 4 || item.branchIndex == 7).toList();
    final activeBranch = widget.navigationShell.currentIndex;
    final activeIndex = displayItems.indexWhere((item) => item.branchIndex == activeBranch);
    final resolvedActive = activeIndex == -1 ? 0 : activeIndex;

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
            _AdminDesktopSidebar(
              navItems: displayItems,
              activeIndex: resolvedActive,
              onNavigate: (index) => widget.navigationShell.goBranch(displayItems[index].branchIndex),
              ref: ref,
            ),
            VerticalDivider(width: 1, thickness: 1, color: border),
            Expanded(child: widget.navigationShell),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: bg,
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: border, width: 1)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(displayItems.length, (i) {
                final isActive = resolvedActive == i;
                return _BottomNavItem(
                  isActive: isActive,
                  selectedColor: AppColors.primary,
                  unselectedColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  surface: surface,
                  item: displayItems[i],
                  onTap: () => widget.navigationShell.goBranch(displayItems[i].branchIndex),
                );
              }),
            ),
          ),
        ),
      );
    }
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int branchIndex;
  const _NavItemData({required this.icon, required this.activeIcon, required this.label, required this.branchIndex});
}

class _BottomNavItem extends StatelessWidget {
  final bool isActive;
  final Color selectedColor;
  final Color unselectedColor;
  final Color surface;
  final _NavItemData item;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.isActive,
    required this.selectedColor,
    required this.unselectedColor,
    required this.surface,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 72, maxWidth: 96),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? selectedColor : unselectedColor,
                size: 22,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: isActive ? 12 : 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? selectedColor : unselectedColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminDesktopSidebar extends StatelessWidget {
  final List<_NavItemData> navItems;
  final int activeIndex;
  final ValueChanged<int> onNavigate;
  final WidgetRef ref;

  const _AdminDesktopSidebar({
    required this.navItems,
    required this.activeIndex,
    required this.onNavigate,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

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
                child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    _OrgNameText(ref: ref),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _OrgFilterDropdown(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(navItems.length, (i) {
                  final item = navItems[i];
                  return Column(
                    children: [
                      _AdminSidebarItem(
                        icon: item.icon,
                        activeIcon: item.activeIcon,
                        label: item.label,
                        isActive: activeIndex == i,
                        onTap: () => onNavigate(i),
                      ),
                      if (i < navItems.length - 1) const SizedBox(height: 8),
                    ],
                  );
                }),
              ),
            ),
          ),
          _LogoutButton(ref: ref),
        ],
      ),
    );
  }
}

class _AdminSidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AdminSidebarItem({
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
            color: isActive ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: AppRadius.roundedSm,
            border: Border.all(
              color: isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
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

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(adminAuthProvider.notifier).logout();
          context.go('/admin/login');
        },
        borderRadius: AppRadius.roundedSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.accent),
              const SizedBox(width: 12),
              Text(
                'Admin Logout',
                style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrgNameText extends ConsumerWidget {
  const _OrgNameText({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final orgId = ref.watch(adminOrganizationIdProvider).asData?.value ?? '';
    if (orgId.isEmpty) return const SizedBox.shrink();
    final orgsAsync = ref.watch(organizationsProvider);
    final orgs = orgsAsync.asData?.value;
    final orgName = orgs != null
        ? orgs.where((o) => o.id == orgId).map((o) => o.name).firstOrNull
        : null;
    return Text(
      orgName ?? orgId,
      style: TextStyle(fontSize: 11, color: textSecondary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _OrgFilterDropdown extends ConsumerWidget {
  const _OrgFilterDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
