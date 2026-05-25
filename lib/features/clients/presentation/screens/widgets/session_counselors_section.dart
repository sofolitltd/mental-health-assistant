import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '../../../../contacts/presentation/providers/contacts_providers.dart';

class _CounselorTile extends ConsumerWidget {
  final String uid;
  final VoidCallback? onRemove;

  const _CounselorTile({required this.uid, this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counselorsAsync = ref.watch(allCounselorsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return counselorsAsync.when(
      data: (all) {
        final c = all.where((c) => c.id == uid).firstOrNull;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  c != null && c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  c != null ? c.name : uid,
                  style: TextStyle(fontSize: 13, color: textPrimary),
                ),
              ),
              if (onRemove != null)
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            const CircleAvatar(radius: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: AppSpacing.sm),
            Text(uid, style: TextStyle(fontSize: 13, color: textPrimary)),
          ],
        ),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(uid, style: TextStyle(fontSize: 13, color: textPrimary)),
      ),
    );
  }
}

class SessionCounselorsSection extends StatelessWidget {
  final String fontFamily;
  final List<String> counselorIds;
  final ValueChanged<String>? onRemoveCounselor;
  final VoidCallback? onAddCounselor;

  const SessionCounselorsSection({
    super.key,
    required this.fontFamily,
    required this.counselorIds,
    this.onRemoveCounselor,
    this.onAddCounselor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

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
            'Counselors',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...counselorIds.map((uid) => _CounselorTile(
            uid: uid,
            onRemove: counselorIds.length <= 1
                ? null
                : (onRemoveCounselor != null ? () => onRemoveCounselor!(uid) : null),
          )),
          if (counselorIds.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text('No counselors assigned.', style: TextStyle(color: textSecondary, fontSize: 13)),
            ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Add Counselor'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
            ),
            onPressed: onAddCounselor,
          ),
        ],
      ),
    );
  }
}
