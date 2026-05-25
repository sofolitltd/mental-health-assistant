import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/design_system/app_design_system.dart';
import '../../../../clients/domain/models/client.dart';

class RecentClients extends StatelessWidget {
  final List<Client> clients;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final String fontFamily;

  const RecentClients({
    super.key,
    required this.clients,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 18, color: textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Recent Clients',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => context.go('/clients'),
                    borderRadius: AppRadius.roundedSm,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: border, height: AppSpacing.md),
            SizedBox(
              height: 2,),
            ...clients.map((c) => _RecentClientTile(
              client: c,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              fontFamily: fontFamily,
            )),
            SizedBox(
              height: AppSpacing.sm,),
          ],
        ),
      ),
    );
  }
}

class _RecentClientTile extends StatelessWidget {
  final Client client;
  final Color textPrimary;
  final Color textSecondary;
  final String fontFamily;

  const _RecentClientTile({
    required this.client,
    required this.textPrimary,
    required this.textSecondary,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/clients/${client.id}/about'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.roundedSm,
              ),
           
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.aliasCode,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    client.dateOfBirth != null ? '${client.gender}, ${client.age} yrs' : client.gender,
                    style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
