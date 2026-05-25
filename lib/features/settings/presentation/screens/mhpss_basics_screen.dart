import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';

class MhppsBasicsScreen extends StatelessWidget {
  const MhppsBasicsScreen({super.key});

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
              'MHPSS Basics',
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
            title: 'What is MHPSS?',
            content: 'Mental Health and Psychosocial Support (MHPSS) refers to any type of local or outside support that aims to protect or promote psychosocial well-being and/or prevent or treat mental health conditions. The term is used by the Inter-Agency Standing Committee (IASC) and is widely adopted by WHO, IFRC, and other humanitarian organizations.\n\n''M — Mental: refers to our emotional, psychological, and social well-being. It affects how we think, feel, and act.\n\n'
                'H — Health: a state of complete physical, mental, and social well-being, not merely the absence of disease.\n\n'
                'P — Psycho: the psychological dimension — thoughts, emotions, and behaviors that shape our experience.\n\n'
                'S — Social: the social dimension — relationships, culture, community, and the environments we live in.\n\n'
                'S — Support: actions that help people cope with challenges, strengthen resilience, and improve well-being.'
                ,
            surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
          ),
          _SectionCard(
            title: 'MHPSS Framework',
            content: 'The IASC MHPSS intervention pyramid outlines four layers of support:\n\n'
                '1. Basic services and security — ensuring safety, food, water, shelter.\n'
                '2. Community and family supports — strengthening social networks and community healing.\n'
                '3. Focused non-specialized supports — Psychological First Aid (PFA) and basic counselling by trained helpers.\n'
                '4. Specialized services — clinical mental health care by professionals for severe conditions.',
            surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
          ),
          _SectionCard(
            title: 'Psychological First Aid (PFA)',
            content: 'PFA is a humane, supportive response to a fellow human being who is suffering and who may need support. It involves:\n\n'
                '• Look — check for safety, people with urgent basic needs, and people with serious distress reactions.\n'
                '• Listen — approach people who may need support, ask about their needs and concerns, and listen without pressure.\n'
                '• Link — help people address basic needs, connect with information, services, and social support.\n\n'
                'PFA is NOT professional counselling or a clinical intervention. It is designed for anyone — volunteers, first responders, community workers.',
            surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
          ),
           _SectionCard(
            title: 'Do No Harm',
            content: 'The "Do No Harm" principle is the foundation of all MHPSS work. Every interaction has the potential to help or harm. Key reminders:\n\n'
                '• Prioritize safety — ensure the environment is safe for both the helper and the person seeking support.\n'
                '• Obtain informed consent — explain who you are, the limits of confidentiality, and let the person choose whether to engage.\n'
                '• Avoid imposing help — do not force support on someone who does not want it. Respect their right to refuse.\n'
                '• Do not probe for details — avoid asking about traumatic experiences in detail. Focus on present needs and coping.\n'
                '• Maintain confidentiality — do not share personal information without explicit permission, except when there is risk of harm.\n'
                '• Know your limits — recognize when a person needs more specialized support and make appropriate referrals.\n'
                '• Take care of yourself — practice self-care and seek support from colleagues. Helping others can be emotionally demanding.\n\n'
                'When in doubt: listen, do not judge, do not advise, and refer when needed.',
            surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
          ),
          
          _SectionCard(
            title: 'Protection, Gender & Inclusion (PGI)',
            content: 'PGI refers to cross-cutting considerations that must be integrated into all MHPSS interventions:\n\n'
                '• Protection — ensure safety and dignity, prevent violence, coercion, and exploitation. Identify and refer protection concerns.\n'
                '• Gender — recognize that women, men, girls, and boys experience crises differently. Ensure equal access to support and address specific needs.\n'
                '• Inclusion — reach marginalized and at-risk groups including persons with disabilities, older adults, ethnic minorities, and LGBTQ+ individuals.\n\n'
                'Key actions:\n'
                '• Use inclusive language and create safe, accessible spaces.\n'
                '• Ask about specific safety concerns without making assumptions.\n'
                '• Ensure activities do not exclude or stigmatize any group.\n'
                '• Coordinate with protection actors for specialized referrals.',
            surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
          ),
          _SectionCard(
            title: 'Basic Counselling Skills',
            content: 'Core skills for effective helping conversations:\n\n'
                '• Active Listening — pay full attention, use verbal and non-verbal cues to show you are listening.\n'
                '• Empathy — understand and reflect the person\'s feelings without judgment.\n'
                '• Open-ended Questions — ask questions that encourage the person to share (e.g. "How are you coping?").\n'
                '• Reflection — paraphrase what the person said to show understanding.\n'
                '• Summarizing — bring together key points to clarify and confirm understanding.\n'
                '• Non-judgmental Attitude — accept the person\'s experience without criticism or advice-giving.',
            surface: surface, textPrimary: textPrimary, textSecondary: textSecondary, border: border, fontFamily: fontFamily,
          ),
          _SectionCard(
            title: 'Basic Counselling Sessions',
            content: 'A simple structure for a counselling session:\n\n'
                '1. Rapport Building — greet warmly, explain purpose, ensure privacy and confidentiality.\n'
                '2. Assessment — ask about the person\'s main concerns, current situation, coping strategies, and support system.\n'
                '3. Exploration — use active listening and open-ended questions to help the person explore their feelings and thoughts.\n'
                '4. Problem-solving — help the person identify practical steps, resources, and coping strategies.\n'
                '5. Closure — summarize the session, agree on follow-up, provide hope and reassurance.',
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
