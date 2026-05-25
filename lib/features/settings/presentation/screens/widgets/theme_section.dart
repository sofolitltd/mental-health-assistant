import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '/core/theme/theme_provider.dart';
import 'settings_card.dart';

class ThemeSection extends StatelessWidget {
  final WidgetRef ref;

  const ThemeSection({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;

    return SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            _ThemeOption(
              title: 'System Default',
              icon: Icons.brightness_auto_rounded,
              isSelected: themeMode == ThemeMode.system,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.system),
            ),
            const Divider(height: 1, indent: 56),
            _ThemeOption(
              title: 'Light Mode',
              icon: Icons.light_mode_rounded,
              isSelected: themeMode == ThemeMode.light,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.light),
            ),
            const Divider(height: 1, indent: 56),
            _ThemeOption(
              title: 'Dark Mode',
              icon: Icons.dark_mode_rounded,
              isSelected: themeMode == ThemeMode.dark,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final clr = isSelected ? AppColors.primary : colors.onSurfaceVariant;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: clr.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: clr, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : colors.onSurface,
          fontSize: 14,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22,
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
