import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '../../../contacts/domain/counselor.dart';
import '../../../contacts/presentation/providers/contacts_providers.dart';

class EditCounselorDialog extends ConsumerStatefulWidget {
  final Counselor counselor;
  const EditCounselorDialog({super.key, required this.counselor});

  @override
  ConsumerState<EditCounselorDialog> createState() => _EditCounselorDialogState();
}

class _EditCounselorDialogState extends ConsumerState<EditCounselorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _designationCtrl;
  late final TextEditingController _employeeIdCtrl;
  late final TextEditingController _phoneCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.counselor.name);
    _designationCtrl = TextEditingController(text: widget.counselor.designation);
    _employeeIdCtrl = TextEditingController(text: widget.counselor.employeeId);
    _phoneCtrl = TextEditingController(text: widget.counselor.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _designationCtrl.dispose();
    _employeeIdCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref.read(counselorRepositoryProvider).updateCounselor(
        uid: widget.counselor.id,
        name: _nameCtrl.text.trim(),
        designation: _designationCtrl.text.trim(),
        employeeId: _employeeIdCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameCtrl.text.trim()} updated.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_rounded, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Edit Counselor',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Field(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      hint: 'e.g. John Doe',
                      icon: Icons.person_outline,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      label: 'Designation',
                      controller: _designationCtrl,
                      hint: 'e.g. Clinical Psychologist',
                      icon: Icons.badge_outlined,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      label: 'Employee ID',
                      controller: _employeeIdCtrl,
                      hint: 'e.g. EMP-001',
                      icon: Icons.confirmation_number_outlined,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      label: 'Phone',
                      controller: _phoneCtrl,
                      hint: 'e.g. +8801XXXXXXXXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _loading ? null : () => Navigator.of(context).pop(),
                          child: Text('Cancel', style: TextStyle(color: textPrimary)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 48),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                          ),
                          child: _loading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
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
          validator: validator,
          style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            hintStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
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