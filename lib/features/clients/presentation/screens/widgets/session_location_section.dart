import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '/core/design_system/app_design_system.dart';

class LatLngField extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color textPrimary;

  const LatLngField({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FC);
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.gps_fixed_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ZoomButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ),
      ),
    );
  }
}

class SessionLocationSection extends StatelessWidget {
  final String fontFamily;
  final double? latitude;
  final double? longitude;
  final DateTime? locationTimestamp;
  final bool isLoading;
  final MapController mapController;
  final VoidCallback onRecord;
  final VoidCallback onRemove;
  final VoidCallback onOpenInMaps;

  const SessionLocationSection({
    super.key,
    required this.fontFamily,
    this.latitude,
    this.longitude,
    this.locationTimestamp,
    this.isLoading = false,
    required this.mapController,
    required this.onRecord,
    required this.onRemove,
    required this.onOpenInMaps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (latitude != null && longitude != null) ...[
                TextButton.icon(
                  onPressed: onRemove,
                  icon: Icon(Icons.close_rounded, size: 16),
                  label: const Text('Remove', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              TextButton.icon(
                onPressed: isLoading ? null : onRecord,
                icon: isLoading
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.my_location_rounded, size: 16),
                label: Text(isLoading ? 'Locating…' : 'Record', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (latitude != null && longitude != null) ...[
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 500;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 220,
                        child: ClipRRect(
                          borderRadius: AppRadius.roundedMd,
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: LatLng(latitude!, longitude!),
                                  initialZoom: 15,
                                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.mh_assistant.app',
                                    tileProvider: CancellableNetworkTileProvider(),
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(latitude!, longitude!),
                                        width: 40,
                                        height: 40,
                                        child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 36),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ZoomButton(
                                      icon: Icons.add_rounded,
                                      onTap: () => mapController.move(
                                        mapController.camera.center,
                                        (mapController.camera.zoom + 1).clamp(1, 19),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ZoomButton(
                                      icon: Icons.remove_rounded,
                                      onTap: () => mapController.move(
                                        mapController.camera.center,
                                        (mapController.camera.zoom - 1).clamp(1, 19),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 280,
                            child: LatLngField(
                              label: 'Latitude',
                              value: latitude!.toStringAsFixed(5),
                              isDark: isDark,
                              textPrimary: textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            width: 280,
                            child: LatLngField(
                              label: 'Longitude',
                              value: longitude!.toStringAsFixed(5),
                              isDark: isDark,
                              textPrimary: textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton.icon(
                            onPressed: onOpenInMaps,
                            icon: Icon(Icons.open_in_new_rounded, size: 16),
                            label: const Text('Open in Google Maps', style: TextStyle(fontSize: 12)),
                          ),
                          if (locationTimestamp != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Recorded: ${DateFormat('MMM dd, yyyy h:mm:ss a').format(locationTimestamp!)}',
                                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: AppRadius.roundedMd,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: LatLng(latitude!, longitude!),
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.mh_assistant.app',
                                tileProvider: CancellableNetworkTileProvider(),
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(latitude!, longitude!),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 36),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ZoomButton(
                                  icon: Icons.add_rounded,
                                  onTap: () => mapController.move(
                                    mapController.camera.center,
                                    (mapController.camera.zoom + 1).clamp(1, 19),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ZoomButton(
                                  icon: Icons.remove_rounded,
                                  onTap: () => mapController.move(
                                    mapController.camera.center,
                                    (mapController.camera.zoom - 1).clamp(1, 19),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: LatLngField(
                          label: 'Latitude',
                          value: latitude!.toStringAsFixed(5),
                          isDark: isDark,
                          textPrimary: textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: LatLngField(
                          label: 'Longitude',
                          value: longitude!.toStringAsFixed(5),
                          isDark: isDark,
                          textPrimary: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onOpenInMaps,
                      icon: Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Open in Google Maps', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  if (locationTimestamp != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Recorded: ${DateFormat('MMM dd, yyyy h:mm:ss a').format(locationTimestamp!)}',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
          ] else if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Acquiring GPS…',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'No location recorded. Tap "Record" to add current location.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
