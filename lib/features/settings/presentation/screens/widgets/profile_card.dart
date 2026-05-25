import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/domain/models/auth_state.dart';
import 'edit_profile_dialog.dart';

class ProfileCard extends StatelessWidget {
  final AuthState authState;

  const ProfileCard({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final joined = authState.joinedAt != null
        ? DateFormat('MMM dd, yyyy').format(authState.joinedAt!)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.name ?? 'User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authState.designation ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.roundedSm,
                  child: InkWell(
                    borderRadius: AppRadius.roundedSm,
                    onTap: () => _showEditDialog(context),
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              label: 'Employee ID',
              value: authState.employeeId ?? '—',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(label: 'Mobile', value: authState.phone ?? '—'),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(label: 'Email', value: authState.email ?? '—'),
            if (joined != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _ProfileRow(label: 'Joined', value: joined),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => EditProfileDialog(authState: authState),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
