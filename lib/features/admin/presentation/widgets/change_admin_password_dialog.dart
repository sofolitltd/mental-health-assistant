import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/data/repositories/auth_repository.dart';
import '../providers/admin_auth_provider.dart';

class ChangeAdminPasswordDialog extends ConsumerStatefulWidget {
  const ChangeAdminPasswordDialog({super.key});

  @override
  ConsumerState<ChangeAdminPasswordDialog> createState() => _ChangeAdminPasswordDialogState();
}

class _ChangeAdminPasswordDialogState extends ConsumerState<ChangeAdminPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final adminDocId = ref.read(adminDocIdProvider).asData?.value ?? '';
      if (adminDocId.isEmpty) throw Exception('Admin session not found.');
      await ref.read(authRepositoryProvider).changeAdminPassword(
        adminDocId: adminDocId,
        currentPassword: _currentPwdCtrl.text.trim(),
        newPassword: _newPwdCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully.'),
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
      maxWidth: 460,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Change Password',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textPrimary)),
                  ]),
                  const SizedBox(height: 4),
                  Text('Enter your current password and a new password.',
                    style: TextStyle(fontSize: 13, color: textPrimary.withValues(alpha: 0.6))),
                  const SizedBox(height: AppSpacing.lg),
                  _buildField(
                    label: 'Current Password',
                    controller: _currentPwdCtrl,
                    obscure: _obscureCurrent,
                    toggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildField(
                    label: 'New Password',
                    controller: _newPwdCtrl,
                    obscure: _obscureNew,
                    toggle: () => setState(() => _obscureNew = !_obscureNew),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Required';
                      if (v!.length < 6) return 'Min. 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildField(
                    label: 'Confirm New Password',
                    controller: _confirmPwdCtrl,
                    obscure: _obscureConfirm,
                    toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Required';
                      if (v != _newPwdCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                        : const Text('Change Password'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: TextStyle(color: textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock_outlined, size: 20, color: textPrimary.withValues(alpha: 0.6)),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
            onPressed: toggle,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: AppRadius.roundedSm, borderSide: BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: AppRadius.roundedSm, borderSide: BorderSide(color: borderColor)),
        ),
      ),
    ]);
  }
}
