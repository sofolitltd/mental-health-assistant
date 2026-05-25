import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design_system/app_design_system.dart';
import 'settings_card.dart';

class DeveloperInfo extends StatelessWidget {
  const DeveloperInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SettingsCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'https://reyad.vercel.app/_next/image?url=%2Freyad1.png&w=256&q=75',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.code_rounded, color: AppColors.primary, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Md Asifuzzaman Reyad',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        'Dept. of Psychology, University of Chittagong',
                        style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                _DevActionTile(
                  icon: Icons.phone_rounded,
                  title: 'Whatsapp',
                  subtitle: '01704340860',
                  onTap: () => launchUrl(Uri.parse('https://wa.me/8801704340860'), mode: LaunchMode.externalApplication),
                ),
                _DevActionTile(
                  icon: Icons.email_rounded,
                  title: 'Gmail',
                  subtitle: 'sofolitlt@gmail.com',
                  onTap: () => launchUrl(Uri.parse('mailto:sofolitlt@gmail.com')),
                ),
                _DevActionTile(
                  icon: Icons.language_rounded,
                  title: 'Portfolio',
                  subtitle: 'reyad.vercel.app',
                  onTap: () => launchUrl(Uri.parse('https://reyad.vercel.app'), mode: LaunchMode.externalApplication),
                ),
                _DevActionTile(
                  icon: Icons.language_rounded,
                  title: 'Founder, Sofol IT',
                  subtitle: 'sofolit.vercel.app',
                  onTap: () => launchUrl(Uri.parse('https://sofolit.vercel.app'), mode: LaunchMode.externalApplication),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DevActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _DevActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: colors.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant))
          : null,
      trailing: Icon(Icons.open_in_new_rounded, size: 16, color: colors.onSurfaceVariant),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
