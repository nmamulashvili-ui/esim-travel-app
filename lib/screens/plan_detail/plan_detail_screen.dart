import 'package:flutter/material.dart';

import '../../config/design_tokens.dart';
import '../../config/routes.dart';
import '../../config/utils.dart';
import '../../models/data_bundle.dart';
import '../../models/esim_plan.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/info_row.dart';

class PlanDetailScreen extends StatefulWidget {
  final EsimPlan plan;
  const PlanDetailScreen({super.key, required this.plan});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  EsimPlan get plan => widget.plan;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final curve = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(curve);
    _slideAnim = Tween(
      begin: const Offset(0, 24),
      end: Offset.zero,
    ).animate(curve);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ─────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppGradients.primaryHeader,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.xxl)),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Back button row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
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
                    // Flag + country
                    Text(flagEmoji(plan.countryCode),
                        style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      plan.country,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      plan.operator,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),

          // ── Plan details card ───────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _enterCtrl,
                builder: (_, child) => Transform.translate(
                  offset: _slideAnim.value,
                  child: Opacity(opacity: _fadeAnim.value, child: child),
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats row
                  Row(
                    children: [
                      _StatPill(
                          icon: Icons.cloud_download_outlined,
                          label: plan.dataAmount),
                      const SizedBox(width: AppSpacing.sm),
                      _StatPill(
                          icon: Icons.schedule_outlined,
                          label: '${plan.validityDays} days'),
                      const SizedBox(width: AppSpacing.sm),
                      _StatPill(
                          icon: Icons.signal_cellular_alt,
                          label: plan.features.isNotEmpty
                              ? plan.features.first
                              : 'LTE'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Specs
                  AppCard(
                    child: Column(
                      children: [
                        InfoRow(
                          icon: Icons.cloud_download_outlined,
                          label: 'Data',
                          value: plan.dataAmount,
                        ),
                        Divider(color: AppColors.divider, height: 1),
                        InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Validity',
                          value: '${plan.validityDays} days',
                        ),
                        Divider(color: AppColors.divider, height: 1),
                        InfoRow(
                          icon: Icons.cell_tower_outlined,
                          label: 'Network',
                          value: plan.operator,
                        ),
                        Divider(color: AppColors.divider, height: 1),
                        InfoRow(
                          icon: Icons.attach_money_rounded,
                          label: 'Price',
                          value: '\$${plan.priceUsd.toStringAsFixed(2)}',
                          iconColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),

                  if (plan.features.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    const SectionHeader(title: 'What\'s included'),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: plan.features
                          .map((f) => Chip(
                                avatar: const Icon(Icons.check_circle,
                                    size: 16, color: AppColors.success),
                                label: Text(f),
                              ))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xxl),
                  const SectionHeader(title: 'How it works'),
                  _StepItem(step: '1', text: 'Purchase your eSIM plan'),
                  _StepItem(step: '2', text: 'Scan the QR code or install manually'),
                  _StepItem(step: '3', text: 'Activate at your destination'),
                ],
              ),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ──────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.md),
            child: Row(
              children: [
                // Price summary
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total',
                        style: theme.textTheme.bodySmall),
                    Text(
                      '\$${plan.priceUsd.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: AppButton(
                    label: 'Buy Now',
                    icon: Icons.shopping_cart_outlined,
                    onPressed: () {
                      final bundle = DataBundle(
                        id: plan.id,
                        region: plan.country,
                        regionCode: plan.countryCode,
                        dataAmount: plan.dataAmount,
                        validityDays: plan.validityDays,
                        priceUsd: plan.priceUsd,
                        features: plan.features,
                      );
                      Navigator.pushNamed(
                        context,
                        AppRoutes.checkout,
                        arguments: bundle,
                      );
                    },
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

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String step;
  final String text;
  const _StepItem({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppGradients.accentCard,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(step,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
