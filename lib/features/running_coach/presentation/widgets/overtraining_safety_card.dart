import 'package:flutter/material.dart';
import 'package:suhat/core/theme/app_theme.dart';

class OvertrainingSafetyCard extends StatelessWidget {
  const OvertrainingSafetyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 16),
          Text(
            'Pencegahan Cedera & Overtraining',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: c.inkPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Prinsip keselamatan lari berkelanjutan',
            style: TextStyle(
              fontSize: 12,
              color: c.inkSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildPrincipleRow(
            c,
            '01',
            'Aturan Kenaikan 10% (10% Rule)',
            'Jangan menaikkan total jarak lari mingguan lebih dari 10% dibanding minggu sebelumnya agar tulang kering dan tendon achilles beradaptasi.',
          ),
          Divider(height: 1, thickness: 1, color: c.hairline),
          _buildPrincipleRow(
            c,
            '02',
            'Pantau Detak Jantung Istirahat (RHR)',
            'Jika detak jantung istirahat pagi naik 5-7 BPM di atas rata-rata normal, sistem saraf belum pulih sepenuhnya dan tubuh perlu istirahat.',
          ),
          Divider(height: 1, thickness: 1, color: c.hairline),
          _buildPrincipleRow(
            c,
            '03',
            'Prioritaskan Tidur untuk Regenerasi',
            'Perbaikan jaringan otot terjadi saat tidur nyenyak (fase Deep Sleep). Upayakan tidur 7-8 jam setiap malam setelah sesi latihan.',
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipleRow(
    SuhatColors c,
    String indexLabel,
    String title,
    String body,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            indexLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: c.accentPine,
              fontFeatures: AppTheme.tabularNumbers,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.inkPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.inkSecondary,
                    height: 1.4,
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
