import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/routes.dart';
import '../../models/data_bundle.dart';
import '../../services/api_service.dart';
import '../../services/bundle_catalog.dart';
import '../../widgets/app_button.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/stagger_list.dart';

class BundlesScreen extends StatefulWidget {
  const BundlesScreen({super.key});

  @override
  State<BundlesScreen> createState() => _BundlesScreenState();
}

class _BundlesScreenState extends State<BundlesScreen> {
  String _selectedRegion = 'Turkey';
  String? _selectedBundleId;
  List<DataBundle> _bundles = [];
  bool _loading = true;

  DataBundle? get _selectedBundle {
    if (_selectedBundleId == null) return null;
    try {
      return _bundles.firstWhere((b) => b.id == _selectedBundleId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBundles();
  }

  Future<void> _loadBundles() async {
    setState(() => _loading = true);
    final api = context.read<ApiService>();
    final result = await api.getBundles(region: _selectedRegion);
    if (!mounted) return;
    setState(() {
      _bundles = result;
      _loading = false;
      _preselectBest();
    });
  }

  void _preselectBest() {
    final best = _bundles.cast<DataBundle?>().firstWhere(
          (b) => b!.tag == BundleTag.bestValue,
          orElse: () =>
              _bundles.isNotEmpty ? _bundles[1 % _bundles.length] : null,
        );
    _selectedBundleId = best?.id;
  }

  void _onRegionChanged(String region) {
    _selectedRegion = region;
    _loadBundles();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selectedBundle;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────
          const GradientHeader(
            title: 'Data Bundles',
            subtitle: 'Choose a plan that fits your trip',
            bottomPadding: AppSpacing.lg,
          ),

          // ── Region chips ────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
              itemCount: BundleCatalog.regions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) {
                final region = BundleCatalog.regions[i];
                final isSelected = region == _selectedRegion;
                return _RegionChip(
                  label: region,
                  isSelected: isSelected,
                  onTap: () => _onRegionChanged(region),
                );
              },
            ),
          ),

          // ── Bundle count label ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xs),
            child: Row(
              children: [
                Text(
                  '${_bundles.length} plans available',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // ── Bundle cards ────────────────────────────────
          Expanded(
            child: _loading
                ? ShimmerLoading(
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xl,
                          AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxl),
                      itemCount: 4,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, __) => const BundleCardSkeleton(),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl,
                        AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxl),
                    itemCount: _bundles.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final bundle = _bundles[i];
                      return StaggeredListItem(
                        index: i,
                        child: _BundleCard(
                          bundle: bundle,
                          isSelected: bundle.id == _selectedBundleId,
                          onTap: () => setState(
                              () => _selectedBundleId = bundle.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ── Sticky bottom bar ───────────────────────────────
      bottomNavigationBar: selected != null
          ? _CheckoutBar(
              bundle: selected,
              onCheckout: () => Navigator.pushNamed(
                context,
                AppRoutes.checkout,
                arguments: selected,
              ),
            )
          : null,
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Region filter chip
// ═════════════════════════════════════════════════════════

class _RegionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected ? AppShadows.colored : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Selectable bundle card
// ═════════════════════════════════════════════════════════

class _BundleCard extends StatelessWidget {
  final DataBundle bundle;
  final bool isSelected;
  final VoidCallback onTap;

  const _BundleCard({
    required this.bundle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.03)
              : AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected ? AppShadows.md : AppShadows.sm,
        ),
        child: Column(
          children: [
            // ── Top row: data icon + info + price ─────────
            Row(
              children: [
                // Data amount circle
                _DataBadge(
                  label: bundle.dataAmount,
                  isSelected: isSelected,
                ),
                const SizedBox(width: AppSpacing.lg),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Data + tag row
                      Row(
                        children: [
                          Text(
                            bundle.dataAmount,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          if (bundle.tag != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            _TagBadge(tag: bundle.tag!),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${bundle.validityDays} days · ${bundle.region}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Price column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${bundle.priceUsd.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (bundle.pricePerDay > 0)
                      Text(
                        '\$${bundle.pricePerDay.toStringAsFixed(2)}/day',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontSize: 11),
                      ),
                  ],
                ),
              ],
            ),

            // ── Features row ──────────────────────────────
            if (bundle.features.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: bundle.features
                      .take(3)
                      .map((f) => _FeatureChip(label: f))
                      .toList(),
                ),
              ),
            ],

            // ── Selection indicator ───────────────────────
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: AppRadius.smAll,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Sub-widgets
// ═════════════════════════════════════════════════════════

/// Circular badge showing the data amount with an icon.
class _DataBadge extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _DataBadge({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final isUnlimited =
        label.toLowerCase().contains('unlim');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: isSelected ? AppGradients.accentCard : null,
        color: isSelected ? null : AppColors.backgroundAlt,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlimited ? Icons.all_inclusive_rounded : Icons.cloud_download_outlined,
            size: 20,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(height: 2),
          Text(
            isUnlimited ? '∞' : label.replaceAll(' GB', ''),
            style: TextStyle(
              fontSize: isUnlimited ? 14 : 13,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small colored pill showing the bundle tag.
class _TagBadge extends StatelessWidget {
  final BundleTag tag;
  const _TagBadge({required this.tag});

  @override
  Widget build(BuildContext context) {
    final (label, color, bgColor) = switch (tag) {
      BundleTag.bestValue => (
          'Best Value',
          AppColors.success,
          AppColors.successLight,
        ),
      BundleTag.popular => (
          'Popular',
          AppColors.accent,
          AppColors.accentLight,
        ),
      BundleTag.unlimited => (
          'Unlimited',
          const Color(0xFF8B5CF6),
          const Color(0xFFEDE9FE),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Tiny feature pill.
class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded,
              size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Sticky checkout bar
// ═════════════════════════════════════════════════════════

class _CheckoutBar extends StatelessWidget {
  final DataBundle bundle;
  final VoidCallback onCheckout;
  const _CheckoutBar({
    required this.bundle,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
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
              // Summary
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bundle.dataAmount} · ${bundle.validityDays} days',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${bundle.priceUsd.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // CTA
              SizedBox(
                width: 170,
                child: AppButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onCheckout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
