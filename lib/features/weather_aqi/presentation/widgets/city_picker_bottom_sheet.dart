import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/weather_aqi_models.dart';

class CityPickerBottomSheet extends StatelessWidget {
  final PresetLocation selectedLocation;
  final ValueChanged<PresetLocation> onSelectLocation;

  const CityPickerBottomSheet({
    super.key,
    required this.selectedLocation,
    required this.onSelectLocation,
  });

  static Future<void> show(
    BuildContext context, {
    required PresetLocation selectedLocation,
    required ValueChanged<PresetLocation> onSelectLocation,
  }) {
    final c = context.suhatColors;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CityPickerBottomSheet(
        selectedLocation: selectedLocation,
        onSelectLocation: onSelectLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: c.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: c.accentPine, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Lokasi Lari',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: c.inkPrimary,
                        ),
                      ),
                      Text(
                        'Cuaca dan kualitas udara (AQI) lokal',
                        style: TextStyle(
                          fontSize: 11,
                          color: c.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup pilihan lokasi',
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: c.inkSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, thickness: 1, color: c.hairline),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.52,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: PresetLocation.defaultPresets.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, thickness: 1, color: c.hairline),
                itemBuilder: (context, index) {
                  final item = PresetLocation.defaultPresets[index];
                  final isSelected = item.name == selectedLocation.name;

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    minVerticalPadding: 10,
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? c.accentPine : c.inkSecondary,
                      size: 20,
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? c.accentPine : c.inkPrimary,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: c.inkSecondary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onSelectLocation(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
