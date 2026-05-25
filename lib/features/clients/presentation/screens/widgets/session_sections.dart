import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';

class SessionStatusSection extends StatelessWidget {
  final String fontFamily;
  final String status;
  final ValueChanged<String> onStatusChanged;

  const SessionStatusSection({
    super.key,
    required this.fontFamily,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: ['scheduled', 'completed', 'cancelled'].map((s) {
              final selected = status == s;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                onSelected: (_) => onStatusChanged(s),
                backgroundColor: isDark ? AppColors.surfaceDark : null,
                selectedColor: s == 'completed'
                    ? Colors.green
                    : s == 'cancelled'
                        ? Colors.red
                        : AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SessionFollowUpSection extends StatelessWidget {
  final String fontFamily;
  final DateTime? followUpDate;
  final VoidCallback onPickDate;
  final VoidCallback? onClearDate;

  const SessionFollowUpSection({
    super.key,
    required this.fontFamily,
    this.followUpDate,
    required this.onPickDate,
    this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow-up Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: onPickDate,
            borderRadius: AppRadius.roundedSm,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                borderRadius: AppRadius.roundedSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 18,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    followUpDate != null
                        ? DateFormat.yMMMd().format(followUpDate!)
                        : 'Set follow-up date (optional)',
                    style: TextStyle(
                      color: followUpDate != null
                          ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    ),
                  ),
                  if (followUpDate != null && onClearDate != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: onClearDate,
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SessionNotesSection extends StatelessWidget {
  final String fontFamily;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SessionNotesSection({
    super.key,
    required this.fontFamily,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Enter session notes...',
              border: OutlineInputBorder(
                borderRadius: AppRadius.roundedSm,
                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
