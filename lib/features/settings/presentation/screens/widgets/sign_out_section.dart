import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import 'settings_card.dart';

class SignOutSection extends StatelessWidget {
  final WidgetRef ref;

  const SignOutSection({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: SettingsListTile(
          title: 'Sign Out',
          icon: Icons.logout_rounded,
          iconColor: AppColors.accent,
          textColor: AppColors.accent,
          onTap: () {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                content: Text(
                  'Are you sure you want to log out of your session?',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
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
                    },
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
