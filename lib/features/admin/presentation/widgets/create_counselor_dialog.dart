import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/data/repositories/auth_repository.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/admin/presentation/providers/admin_data_provider.dart';

class CreateCounselorDialog extends ConsumerStatefulWidget {
  const CreateCounselorDialog({super.key});

  @override
  ConsumerState<CreateCounselorDialog> createState() => _CreateCounselorDialogState();
}

class _CreateCounselorDialogState extends ConsumerState<CreateCounselorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _employeeIdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _designationCtrl.dispose();
    _employeeIdCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final orgId = ref.read(adminEffectiveOrgIdProvider);
      if (orgId == null || orgId.isEmpty) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Select an organization filter first before creating a counselor.'),
              backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating),
          );
        }
        return;
      }

      final repo = ref.read(authRepositoryProvider);
      await repo.adminCreateCounselor(
        organizationId: orgId,
        employeeId: _employeeIdCtrl.text.trim(),
        designation: _designationCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Counselor "${_nameCtrl.text.trim()}" created. Share the temporary password with them.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final orgId = ref.watch(adminEffectiveOrgIdProvider);

    String? orgName;
    if (orgId != null && orgId.isNotEmpty) {
      final orgs = ref.watch(organizationsProvider).asData?.value ?? [];
      orgName = orgs.where((o) => o.id == orgId).map((o) => o.name).firstOrNull;
    }

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
                        const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Create Counselor Account',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set a temporary password for the counselor. They can change it after logging in.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: AppRadius.roundedSm,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.business_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              orgName != null ? 'Organization: $orgName' : 'Select an organization filter first',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: orgName != null ? AppColors.primary : AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                    const SizedBox(height: AppSpacing.md),

                    _Field(
                      label: 'Email Address',
                      controller: _emailCtrl,
                      hint: 'e.g. john@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Required';
                        if (!v!.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      label: 'Temporary Password',
                      controller: _passwordCtrl,
                      hint: 'Min. 6 characters',
                      icon: Icons.lock_outlined,
                      obscureText: true,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Required';
                        if (v!.length < 6) return 'Min. 6 characters';
                        return null;
                      },
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
                          onPressed: (_loading || orgName == null) ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 48),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                          ),
                          child: _loading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Create Account'),
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
  final bool obscureText;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
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
          obscureText: obscureText,
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
