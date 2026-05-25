import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/design_system/app_design_system.dart';
import 'settings_card.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            SettingsListTile(
              title: 'MHPSS Basics',
              icon: Icons.help_center_outlined,
              onTap: () => context.go('/settings/mhpss-basics'),
            ),
            const Divider(height: 1, indent: 56),
            SettingsListTile(
              title: 'Attention Required',
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () => context.go('/settings/attention-required'),
            ),
            const Divider(height: 1, indent: 56),
            SettingsListTile(
              title: 'Privacy & Security',
              icon: Icons.security_rounded,
              onTap: () => context.go('/settings/privacy'),
            ),
          ],
        ),
      ),
    );
  }
}
