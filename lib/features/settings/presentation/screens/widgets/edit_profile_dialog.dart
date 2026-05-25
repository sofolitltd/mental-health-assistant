import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/domain/models/auth_state.dart';
import '/features/auth/presentation/providers/auth_providers.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final AuthState authState;

  const EditProfileDialog({super.key, required this.authState});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final TextEditingController _nameCtl;
  late final TextEditingController _empCtl;
  late final TextEditingController _desigCtl;
  late final TextEditingController _phoneCtl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.authState.name);
    _empCtl = TextEditingController(text: widget.authState.employeeId);
    _desigCtl = TextEditingController(text: widget.authState.designation);
    _phoneCtl = TextEditingController(text: widget.authState.phone);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _empCtl.dispose();
    _desigCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_outlined, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Edit Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DialogField(
                    controller: _nameCtl,
                    label: 'Name',
                    hint: 'Enter your name',
                    prefixIcon: Icons.person_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogField(
                    controller: _empCtl,
                    label: 'Employee ID',
                    hint: 'e.g. EMP-001',
                    prefixIcon: Icons.badge_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogField(
                    controller: _desigCtl,
                    label: 'Designation',
                    hint: 'e.g. Counselor',
                    prefixIcon: Icons.work_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogField(
                    controller: _phoneCtl,
                    label: 'Mobile',
                    hint: 'Enter phone number',
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_rounded,
                          size: 20,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.authState.email ?? '',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _saving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedMd,
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final uid = widget.authState.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('counselors').doc(uid).update({
      'name': _nameCtl.text.trim(),
      'employeeId': _empCtl.text.trim(),
      'designation': _desigCtl.text.trim(),
      'phone': _phoneCtl.text.trim(),
    });

    ref
        .read(authProvider.notifier)
        .updateProfile(
          name: _nameCtl.text.trim(),
          employeeId: _empCtl.text.trim(),
          designation: _desigCtl.text.trim(),
          phone: _phoneCtl.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon,
                size: 20,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            hintStyle: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.roundedSm,
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedSm,
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
