import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/developer_info.dart';
import 'widgets/profile_card.dart';
import 'widgets/settings_card.dart';
import 'widgets/sign_out_section.dart';
import 'widgets/support_section.dart';
import 'widgets/theme_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: MaxWidthContainer(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: GoogleFonts.outfit().fontFamily,
                  ),
                ),
                floating: true,
                snap: true,
                centerTitle: false,
              ),
              SliverToBoxAdapter(child: ProfileCard(authState: authState)),
              SliverToBoxAdapter(child: SectionHeader(title: 'Account')),
              SliverToBoxAdapter(child: SettingsCard(child: Column(children: [
                SettingsListTile(
                  title: 'Change Password',
                  icon: Icons.lock_outline_rounded,
                  onTap: () => showDialog(context: context, builder: (_) => const ChangePasswordDialog()),
                ),
              ]))),
              SliverToBoxAdapter(child: SectionHeader(title: 'Appearance')),
              SliverToBoxAdapter(child: ThemeSection(ref: ref)),
              SliverToBoxAdapter(child: SectionHeader(title: 'MHPSS Basics')),
              SliverToBoxAdapter(child: const SupportSection()),
              SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
              SliverToBoxAdapter(child: SignOutSection(ref: ref)),
              SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xxl)),
              SliverToBoxAdapter(child: SectionHeader(title: 'Developer')),
              SliverToBoxAdapter(child: const DeveloperInfo()),
              SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }
}
