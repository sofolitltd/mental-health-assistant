import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';

class QuickStats extends StatelessWidget {
  final int clientCount;
  final int weekSessionCount;
  final int weekAssessmentCount;
  final int newClientsThisWeek;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final String fontFamily;

  const QuickStats({
    super.key,
    required this.clientCount,
    required this.weekSessionCount,
    required this.weekAssessmentCount,
    required this.newClientsThisWeek,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _StatCard(
              icon: Icons.people_outline_rounded,
              label: 'Clients',
              value: '$clientCount',
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              surface: surface,
              fontFamily: fontFamily,
            )),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatCard(
              icon: Icons.event_available_rounded,
              label: 'Sessions',
              value: '$weekSessionCount',
              sublabel: 'this week',
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              surface: surface,
              fontFamily: fontFamily,
            )),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatCard(
              icon: Icons.assignment_outlined,
              label: 'Assessments',
              value: '$weekAssessmentCount',
              sublabel: 'this week',
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              surface: surface,
              fontFamily: fontFamily,
            )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sublabel;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final String fontFamily;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.sublabel,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              fontFamily: fontFamily,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily),
          ),
          if (sublabel != null)
            Text(
              sublabel!,
              style: TextStyle(fontSize: 10, color: textSecondary.withOpacity(0.7), fontFamily: fontFamily),
            ),
        ],
      ),
    );
  }
}
