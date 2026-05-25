import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/presentation/providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _designationController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employeeIdFocusNode = FocusNode();
  final _designationFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String? _selectedOrgId;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _orgNameController.dispose();
    _employeeIdController.dispose();
    _designationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _employeeIdFocusNode.dispose();
    _designationFocusNode.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final organizationsAsync = ref.watch(organizationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: MaxWidthContainer(
            maxWidth: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    onPressed: () => context.go('/login'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Join our professional mental health network',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: AppRadius.roundedLg,
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Organization Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: rfs(context, 14),
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        organizationsAsync.when(
                          data: (orgs) => SearchAnchor(
                            builder: (context, controller) {
                              return TextFormField(
                                controller: _orgNameController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Select organization',
                                  prefixIcon: Icon(
                                    Icons.business_outlined,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.roundedMd,
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppRadius.roundedMd,
                                    borderSide: BorderSide(
                                      color: isDark ? AppColors.borderDark : AppColors.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: AppRadius.roundedMd,
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(
                                    AppSpacing.md,
                                  ),
                                ),
                                onTap: () => controller.openView(),
                                validator: (v) {
                                  if (v?.isEmpty ?? true)
                                    return 'Please select an organization';
                                  if (_selectedOrgId == null)
                                    return 'Invalid selection';
                                  return null;
                                },
                              );
                            },
                            suggestionsBuilder: (context, controller) {
                              final keyword = controller.text.toLowerCase();
                              final filteredOrgs = orgs
                                  .where(
                                    (org) => org.name.toLowerCase().contains(
                                      keyword,
                                    ),
                                  )
                                  .toList();

                              if (filteredOrgs.isEmpty) {
                                return [
                                  ListTile(
                                    title: Text(
                                      'No organization found',
                                      style: TextStyle(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ];
                              }

                              return filteredOrgs.map(
                                (org) => ListTile(
                                  title: Text(org.name),
                                  onTap: () {
                                    setState(() {
                                      _orgNameController.text = org.name;
                                      _selectedOrgId = org.id; // Store the ID
                                      if (org.code != null) {
                                        _employeeIdController.text = org.code!;
                                      }
                                    });
                                    controller.closeView(org.name);
                                  },
                                ),
                              );
                            },
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (err, _) => Text(
                            'Error loading organizations',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CustomTextField(
                          isDark: isDark,
                          controller: _employeeIdController,
                          focusNode: _employeeIdFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Employee ID',
                          hint: 'Enter employee ID',
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Enter employee ID' : null,
                          onFieldSubmitted: () => _designationFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CustomTextField(
                          isDark: isDark,
                          controller: _designationController,
                          focusNode: _designationFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Designation',
                          hint: 'e.g. Psychologist, Counselor',
                          prefixIcon: Icons.work_outline,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Enter designation' : null,
                          onFieldSubmitted: () => _nameFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CustomTextField(
                          isDark: isDark,
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Your Name',
                          hint: 'Enter your full name',
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Enter your name' : null,
                          onFieldSubmitted: () => _phoneFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CustomTextField(
                          isDark: isDark,
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Phone Number',
                          hint: 'Enter phone number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Enter phone number' : null,
                          onFieldSubmitted: () => _emailFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: AppRadius.roundedSm,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Text(
                                  'Use this email and password to log in later.',
                                  style: TextStyle(
                                    fontSize: rfs(context, 13),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CustomTextField(
                          isDark: isDark,
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Email Address',
                          hint: 'name@clinic.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Enter email';
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v!)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          onFieldSubmitted: () => _passwordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CustomTextField(
                          isDark: isDark,
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          label: 'Password',
                          hint: 'Create a password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Enter password';
                            if (v!.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    ref
                                        .read(authProvider.notifier)
                                        .register(
                                          organizationId: _selectedOrgId!,
                                          employeeId:
                                              _employeeIdController.text,
                                          designation:
                                              _designationController.text,
                                          name: _nameController.text,
                                          phone: _phoneController.text,
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        );
                                  }
                                },
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                 TextButton(
                   onPressed: () => context.go('/login'),
                   child: RichText(
                     text: TextSpan(
                       text: "Already have an account? ",
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                         color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                       ),
                       children: [
                         TextSpan(
                           text: 'Sign In',
                           style: TextStyle(
                             color: AppColors.primary,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final bool isDark;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onFieldSubmitted;

  const _CustomTextField({
    required this.isDark,
    required this.controller,
    this.focusNode,
    this.textInputAction,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rfs(context, 14),
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: textInputAction,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onFieldSubmitted: (_) => onFieldSubmitted?.call(),
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
            border: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }
}
