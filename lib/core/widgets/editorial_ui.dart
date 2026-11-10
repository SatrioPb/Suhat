import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../../features/analytics/domain/models/health_insight.dart';
import '../../features/analytics/domain/models/heart_rate_analysis.dart';
import '../../features/analytics/domain/models/sleep_analysis.dart';

/// Resolusi warna terpusat agar seluruh status & metrik konsisten di mode Terang & Gelap
class EditorialStatusColors {
  static Color recovery(RecoveryLevel level, SuhatColors c) {
    switch (level) {
      case RecoveryLevel.optimal:
      case RecoveryLevel.good:
        return c.accentPine;
      case RecoveryLevel.attentionNeeded:
        return c.statusCaution;
      case RecoveryLevel.restRequired:
        return c.statusAlert;
      case RecoveryLevel.insufficientData:
        return c.inkSecondary;
    }
  }

  static Color heartRate(HeartRateStatus status, SuhatColors c) {
    switch (status) {
      case HeartRateStatus.normal:
        return c.accentPine;
      case HeartRateStatus.elevated:
        return c.statusCaution;
      case HeartRateStatus.bradycardia:
        return c.inkSecondary;
      case HeartRateStatus.tachycardia:
        return c.statusAlert;
      case HeartRateStatus.insufficientData:
        return c.inkSecondary;
    }
  }

  static Color sleepDuration(SleepDurationCategory cat, SuhatColors c) {
    switch (cat) {
      case SleepDurationCategory.optimal:
      case SleepDurationCategory.fair:
        return c.accentPine;
      case SleepDurationCategory.short:
        return c.statusCaution;
      case SleepDurationCategory.long:
      case SleepDurationCategory.noData:
        return c.inkSecondary;
    }
  }

  static Color runningZone(int zoneNumber, SuhatColors c) {
    switch (zoneNumber) {
      case 1:
        return c.inkSecondary;
      case 2:
        return c.accentPine;
      case 3:
      case 4:
        return c.statusCaution;
      case 5:
        return c.statusAlert;
      default:
        return c.inkPrimary;
    }
  }
}

/// Tag status fungsional bergaya editorial (radius 4px, selalu ikon + teks)
class EditorialStatusTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const EditorialStatusTag({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item metrik tabular untuk strip responsif
class EditorialMetricItem {
  final String label;
  final String value;
  final String? unit;
  final String? subtext;
  final Color? valueColor;

  const EditorialMetricItem({
    required this.label,
    required this.value,
    this.unit,
    this.subtext,
    this.valueColor,
  });
}

/// Deretan metrik tabular yang melipat otomatis di layar sempit atau pembesaran teks 200%
class EditorialMetricStrip extends StatelessWidget {
  final List<EditorialMetricItem> items;
  final double collapseBreakpoint;

  const EditorialMetricStrip({
    super.key,
    required this.items,
    this.collapseBreakpoint = 310,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack =
            constraints.maxWidth < collapseBreakpoint || textScale > 1.35;

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _buildCell(items[i], c, alignCenter: false),
                if (i < items.length - 1)
                  Divider(height: 16, thickness: 1, color: c.hairline),
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(child: _buildCell(items[i], c, alignCenter: false)),
                if (i < items.length - 1)
                  VerticalDivider(
                    width: 20,
                    thickness: 1,
                    color: c.hairline,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCell(
    EditorialMetricItem item,
    SuhatColors c, {
    required bool alignCenter,
  }) {
    return Column(
      crossAxisAlignment:
          alignCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: c.inkSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 4,
          children: [
            Text(
              item.value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: item.valueColor ?? c.inkPrimary,
                fontFeatures: AppTheme.tabularNumbers,
                letterSpacing: -0.3,
              ),
            ),
            if (item.unit != null && item.unit!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  item.unit!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.inkSecondary,
                  ),
                ),
              ),
          ],
        ),
        if (item.subtext != null && item.subtext!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            item.subtext!,
            style: TextStyle(
              fontSize: 11,
              color: c.inkSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Pemberitahuan status (Loading, Error, Empty, Permission) beserta langkah lanjutan
class EditorialStateNotice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showProgress;

  const EditorialStateNotice({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final disableAnim = MediaQuery.disableAnimationsOf(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showProgress && !disableAnim)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.inkPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: c.inkSecondary,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tombol toggle Tema Terang/Gelap ringkas untuk AppBar
class ThemeToggleIconButton extends ConsumerWidget {
  const ThemeToggleIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final c = context.suhatColors;

    return IconButton(
      tooltip: isDark ? 'Beralih ke Mode Terang' : 'Beralih ke Mode Gelap',
      onPressed: () {
        ref.read(themeModeProvider.notifier).toggleLightDark(brightness);
      },
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: c.inkPrimary,
      ),
    );
  }
}
