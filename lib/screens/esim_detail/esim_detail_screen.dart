import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/design_tokens.dart';
import '../../config/utils.dart';
import '../../models/user_esim.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/info_row.dart';

class EsimDetailScreen extends StatelessWidget {
  final UserEsim esim;
  const EsimDetailScreen({super.key, required this.esim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ═══════════════════════════════════════════════
          //  Header with QR code
          // ═══════════════════════════════════════════════
          SliverToBoxAdapter(child: _HeroHeader(esim: esim)),

          // ═══════════════════════════════════════════════
          //  Body content
          // ═══════════════════════════════════════════════
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xxxxl),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status banner ────────────────────────
                  _StatusBanner(esim: esim),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Data usage ───────────────────────────
                  const SectionHeader(title: 'Data Usage'),
                  _DataUsageCard(esim: esim),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Validity ─────────────────────────────
                  const SectionHeader(title: 'Validity'),
                  _ValidityCard(esim: esim),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Installation steps ───────────────────
                  const SectionHeader(title: 'How to Install'),
                  _InstallSteps(),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── eSIM details ─────────────────────────
                  const SectionHeader(title: 'eSIM Details'),
                  _DetailsCard(esim: esim),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Manual install ───────────────────────
                  const SectionHeader(title: 'Manual Installation'),
                  _ManualInstallCard(esim: esim),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Help ─────────────────────────────────
                  AppButton.outline(
                    label: 'Need help?',
                    icon: Icons.support_agent_outlined,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Gradient header with QR code
// ═════════════════════════════════════════════════════════

class _HeroHeader extends StatelessWidget {
  final UserEsim esim;
  const _HeroHeader({required this.esim});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryHeader,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(AppRadius.xxl)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Nav row
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: esim.isActive
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.12),
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: esim.isActive
                                ? AppColors.primaryLight
                                : Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          esim.isActive ? 'Active' : 'Expired',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: Colors.white70),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Country info
            Text(flagEmoji(esim.countryCode),
                style: const TextStyle(fontSize: 44)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              esim.country,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              esim.operator,
              style: TextStyle(
                  fontSize: 13, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // QR code floating card
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xxxxl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.xlAll,
                boxShadow: AppShadows.lg,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  _QrCode(seed: esim.iccid.hashCode),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Scan to install eSIM',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tap to enlarge hint
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundAlt,
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(AppRadius.xl)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fullscreen_rounded,
                            size: 16, color: AppColors.textTertiary),
                        SizedBox(width: 6),
                        Text(
                          'Tap to enlarge',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Status banner
// ═════════════════════════════════════════════════════════

class _StatusBanner extends StatelessWidget {
  final UserEsim esim;
  const _StatusBanner({required this.esim});

  @override
  Widget build(BuildContext context) {
    final isActive = esim.isActive;
    final bgColor = isActive ? AppColors.successLight : AppColors.backgroundAlt;
    final fgColor = isActive ? AppColors.success : AppColors.textTertiary;
    final icon =
        isActive ? Icons.check_circle_rounded : Icons.cancel_outlined;
    final label = isActive
        ? 'Your eSIM is active and ready to use'
        : 'This eSIM has expired';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.lgAll,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: fgColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Data usage card
// ═════════════════════════════════════════════════════════

class _DataUsageCard extends StatelessWidget {
  final UserEsim esim;
  const _DataUsageCard({required this.esim});

  @override
  Widget build(BuildContext context) {
    final fraction = esim.usageFraction;
    final barColor = fraction > 0.9
        ? AppColors.error
        : fraction > 0.75
            ? AppColors.warning
            : AppColors.primary;

    return AppCard(
      elevated: true,
      child: Column(
        children: [
          // Stat pills row
          Row(
            children: [
              _StatPill(
                icon: Icons.arrow_upward_rounded,
                label: 'Used',
                value: esim.dataUsed,
                color: barColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatPill(
                icon: Icons.arrow_downward_rounded,
                label: 'Remaining',
                value: esim.dataRemaining,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatPill(
                icon: Icons.data_usage_rounded,
                label: 'Total',
                value: esim.dataAmount,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Usage bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(fraction * 100).toInt()}% used',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: barColor,
                    ),
                  ),
                  Text(
                    '${esim.dataUsed} of ${esim.dataAmount}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.pillAll,
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 10,
                  backgroundColor: AppColors.backgroundAlt,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Validity card
// ═════════════════════════════════════════════════════════

class _ValidityCard extends StatelessWidget {
  final UserEsim esim;
  const _ValidityCard({required this.esim});

  @override
  Widget build(BuildContext context) {
    final fraction = esim.totalDays > 0
        ? ((esim.totalDays - esim.daysLeft) / esim.totalDays).clamp(0.0, 1.0)
        : 1.0;
    final isExpired = !esim.isActive;

    return AppCard(
      elevated: true,
      child: Row(
        children: [
          // Days circle
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: fraction,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.backgroundAlt,
                    valueColor: AlwaysStoppedAnimation(
                      isExpired ? AppColors.textTertiary : AppColors.accent,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${esim.daysLeft}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isExpired
                            ? AppColors.textTertiary
                            : AppColors.accent,
                      ),
                    ),
                    const Text('days',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpired
                      ? 'Plan expired'
                      : '${esim.daysLeft} days remaining',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isExpired
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${esim.totalDays}-day plan · ${esim.totalDays - esim.daysLeft} days used',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textTertiary),
                ),
                if (!isExpired) ...[
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: AppRadius.pillAll,
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 4,
                      backgroundColor: AppColors.backgroundAlt,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Installation steps
// ═════════════════════════════════════════════════════════

class _InstallSteps extends StatelessWidget {
  static const _steps = <_StepData>[
    _StepData(
      number: '1',
      title: 'Scan QR Code',
      description: 'Open your camera or go to Settings → Cellular → Add eSIM. '
          'Point at the QR code above.',
      icon: Icons.qr_code_scanner_rounded,
    ),
    _StepData(
      number: '2',
      title: 'Install eSIM',
      description: 'Follow the on-screen prompts to download and install the '
          'eSIM profile to your device.',
      icon: Icons.download_rounded,
    ),
    _StepData(
      number: '3',
      title: 'Activate',
      description: 'Turn on the eSIM in your device settings when you arrive '
          'at your destination. Enable data roaming.',
      icon: Icons.cell_tower_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: true,
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          for (var i = 0; i < _steps.length; i++) ...[
            _StepTile(step: _steps[i], isLast: i == _steps.length - 1),
            if (i < _steps.length - 1)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(height: 1, color: AppColors.divider),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  const _StepData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _StepTile extends StatelessWidget {
  final _StepData step;
  final bool isLast;
  const _StepTile({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: AppGradients.accentCard,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              step.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(step.icon, size: 16, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.45,
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

// ═════════════════════════════════════════════════════════
//  eSIM details card
// ═════════════════════════════════════════════════════════

class _DetailsCard extends StatelessWidget {
  final UserEsim esim;
  const _DetailsCard({required this.esim});

  String _formatIccid(String iccid) {
    if (iccid.length <= 8) return iccid;
    return '${iccid.substring(0, 4)} •••• ${iccid.substring(iccid.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          InfoRow(
            icon: Icons.sim_card_outlined,
            label: 'ICCID',
            value: _formatIccid(esim.iccid),
          ),
          const Divider(height: 1, color: AppColors.divider),
          InfoRow(
            icon: Icons.cloud_download_outlined,
            label: 'Data plan',
            value: esim.dataAmount,
          ),
          const Divider(height: 1, color: AppColors.divider),
          InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Validity',
            value: '${esim.totalDays} days',
          ),
          const Divider(height: 1, color: AppColors.divider),
          InfoRow(
            icon: Icons.cell_tower_outlined,
            label: 'Network',
            value: esim.operator,
          ),
          const Divider(height: 1, color: AppColors.divider),
          InfoRow(
            icon: esim.isActive
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            label: 'Status',
            value: esim.isActive ? 'Active' : 'Expired',
            iconColor: esim.isActive ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Manual installation card
// ═════════════════════════════════════════════════════════

class _ManualInstallCard extends StatelessWidget {
  final UserEsim esim;
  const _ManualInstallCard({required this.esim});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings_outlined,
                  size: 18, color: AppColors.textTertiary),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Can\'t scan the QR code?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Enter these details manually in your device cellular settings.',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _CopyField(label: 'SM-DP+ Address', value: 'smdp.esim-market.io'),
          const SizedBox(height: AppSpacing.md),
          _CopyField(
            label: 'Activation Code',
            value: 'ESIM-${esim.id.toUpperCase()}-${esim.iccid.substring(esim.iccid.length - 4)}',
          ),
        ],
      ),
    );
  }
}

class _CopyField extends StatelessWidget {
  final String label;
  final String value;
  const _CopyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Material(
          color: AppColors.backgroundAlt,
          borderRadius: AppRadius.mdAll,
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: const Icon(Icons.copy_rounded,
                        size: 14, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════
//  QR Code (CustomPaint with proper finder patterns)
// ═════════════════════════════════════════════════════════

class _QrCode extends StatelessWidget {
  final int seed;
  const _QrCode({required this.seed});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(180, 180),
      painter: _QrPainter(seed: seed),
    );
  }
}

class _QrPainter extends CustomPainter {
  final int seed;
  _QrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    const modules = 25;
    final cellSize = size.width / (modules + 2); // +2 for quiet zone
    final offset = cellSize; // quiet zone offset
    final rng = Random(seed);

    final dark = Paint()..color = const Color(0xFF0F172A);
    final brand = Paint()..color = AppColors.primary;

    // Draw data modules
    for (var r = 0; r < modules; r++) {
      for (var c = 0; c < modules; c++) {
        if (_isFinderArea(r, c, modules)) continue;
        if (_isTimingPattern(r, c)) continue;

        if (rng.nextDouble() > 0.45) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              offset + c * cellSize,
              offset + r * cellSize,
              cellSize - 0.6,
              cellSize - 0.6,
            ),
            const Radius.circular(1.2),
          );
          canvas.drawRRect(rect, dark);
        }
      }
    }

    // Timing patterns
    for (var i = 8; i < modules - 8; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(
              offset + i * cellSize, offset + 6 * cellSize, cellSize - 0.6, cellSize - 0.6),
          dark,
        );
        canvas.drawRect(
          Rect.fromLTWH(
              offset + 6 * cellSize, offset + i * cellSize, cellSize - 0.6, cellSize - 0.6),
          dark,
        );
      }
    }

    // Draw finder patterns (3 corners)
    _drawFinder(canvas, offset, offset, cellSize, brand);
    _drawFinder(
        canvas, offset + (modules - 7) * cellSize, offset, cellSize, brand);
    _drawFinder(
        canvas, offset, offset + (modules - 7) * cellSize, cellSize, brand);

    // Small alignment pattern in bottom-right area
    _drawAlignment(
        canvas,
        offset + (modules - 9) * cellSize,
        offset + (modules - 9) * cellSize,
        cellSize,
        dark);
  }

  void _drawFinder(
      Canvas canvas, double x, double y, double cell, Paint paint) {
    final bg = Paint()..color = Colors.white;

    // Outer 7×7
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, cell * 7 - 0.6, cell * 7 - 0.6),
        const Radius.circular(3),
      ),
      paint,
    );
    // White 5×5
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            x + cell, y + cell, cell * 5 - 0.6, cell * 5 - 0.6),
        const Radius.circular(2),
      ),
      bg,
    );
    // Inner 3×3
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            x + cell * 2, y + cell * 2, cell * 3 - 0.6, cell * 3 - 0.6),
        const Radius.circular(1.5),
      ),
      paint,
    );
  }

  void _drawAlignment(
      Canvas canvas, double x, double y, double cell, Paint paint) {
    final bg = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, cell * 5 - 0.6, cell * 5 - 0.6),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            x + cell, y + cell, cell * 3 - 0.6, cell * 3 - 0.6),
        const Radius.circular(1),
      ),
      bg,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          x + cell * 2, y + cell * 2, cell - 0.6, cell - 0.6),
      paint,
    );
  }

  bool _isFinderArea(int r, int c, int size) {
    // Top-left 8×8
    if (r < 8 && c < 8) return true;
    // Top-right 8×8
    if (r < 8 && c >= size - 8) return true;
    // Bottom-left 8×8
    if (r >= size - 8 && c < 8) return true;
    return false;
  }

  bool _isTimingPattern(int r, int c) {
    return (r == 6 && c >= 8) || (c == 6 && r >= 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
