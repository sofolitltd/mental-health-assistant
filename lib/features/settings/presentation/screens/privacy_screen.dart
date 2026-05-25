import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MaxWidthContainer(
          child: AppBar(
            backgroundColor: bg,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              onPressed: () => context.go('/settings'),
            ),
            title: Text(
              'Privacy & Security',
              style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: MaxWidthContainer(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _SectionCard(
              title: 'Data Collection & Use',
              content: 'This application collects and stores personal information including client names, contact details, session notes, assessment results, and counselor records. This data is used solely for the purpose of providing mental health support services and maintaining professional records.',
              surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
            ),
            _SectionCard(
              title: 'Data Storage & Security',
              content: 'All data is encrypted in transit and at rest using industry-standard encryption protocols. Data is stored securely on Firebase servers with access restricted to authorized users only. You are responsible for maintaining the confidentiality of your login credentials.',
              surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
            ),
            _SectionCard(
              title: 'Confidentiality',
              content: 'Session notes, assessment results, and client information are confidential and are only accessible to the counselor who created them and authorized administrators. We do not share client data with third parties except as required by law or with explicit client consent.',
              surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
            ),
            _SectionCard(
              title: 'User Responsibilities',
              content: 'As a user of this platform, you agree to:\n\n'
                  '• Maintain the privacy and confidentiality of client information.\n'
                  '• Use the platform only for legitimate professional purposes.\n'
                  '• Ensure your device and account are secured with strong passwords.\n'
                  '• Report any security breaches or unauthorized access immediately.\n'
                  '• Comply with all applicable data protection laws and ethical guidelines.',
              surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
            ),
            _SectionCard(
              title: 'Data Retention & Deletion',
              content: 'Client records are retained for the duration of the professional relationship and as required by applicable laws and regulations. You may request deletion of your account and associated data by contacting your system administrator. Deletion of certain data may be restricted by legal or regulatory requirements.',
              surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
            ),
            _SectionCard(
              title: 'Contact',
              content: 'For questions about this privacy policy or to exercise your data protection rights, please contact your organization\'s data protection officer or system administrator.',
              surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String content;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final String fontFamily;

  const _SectionCard({
    required this.title,
    required this.content,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textPrimary,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              fontFamily: fontFamily,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
