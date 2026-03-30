import 'package:flutter/material.dart';

import '../config/design_tokens.dart';

/// A shimmer effect that sweeps across child [shapes].
/// Use inside loading states instead of a bare spinner.
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0xFFE2E8F0),
              Color(0xFFF1F5F9),
              Color(0xFFE2E8F0),
            ],
            stops: [
              (_ctrl.value - 0.3).clamp(0, 1),
              _ctrl.value,
              (_ctrl.value + 0.3).clamp(0, 1),
            ],
          ).createShader(bounds);
        },
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// A single shimmer bone (rounded rectangle placeholder).
class ShimmerBone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBone({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Pre-built skeleton that mimics a [PlanCard].
class PlanCardSkeleton extends StatelessWidget {
  const PlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            ShimmerBone(width: 52, height: 52, radius: AppRadius.lg),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBone(width: 120, height: 14),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      ShimmerBone(width: 48, height: 20, radius: AppRadius.pill),
                      const SizedBox(width: AppSpacing.sm),
                      ShimmerBone(width: 32, height: 20, radius: AppRadius.pill),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ShimmerBone(width: 56, height: 18),
          ],
        ),
      ),
    );
  }
}

/// Pre-built skeleton that mimics a bundle card.
class BundleCardSkeleton extends StatelessWidget {
  const BundleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBone(width: 56, height: 56, radius: AppRadius.lg),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShimmerBone(width: 80, height: 16),
                        const SizedBox(width: AppSpacing.sm),
                        ShimmerBone(width: 52, height: 18, radius: AppRadius.pill),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ShimmerBone(width: 140, height: 12),
                  ],
                ),
              ),
              ShimmerBone(width: 60, height: 24, radius: AppRadius.pill),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              ShimmerBone(width: 48, height: 20, radius: AppRadius.pill),
              const SizedBox(width: AppSpacing.sm),
              ShimmerBone(width: 32, height: 20, radius: AppRadius.pill),
              const SizedBox(width: AppSpacing.sm),
              ShimmerBone(width: 56, height: 20, radius: AppRadius.pill),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pre-built skeleton that mimics a My eSIM card.
class EsimCardSkeleton extends StatelessWidget {
  const EsimCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    ShimmerBone(width: 48, height: 48, radius: AppRadius.md),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBone(width: 100, height: 14),
                          const SizedBox(height: AppSpacing.sm),
                          ShimmerBone(width: 80, height: 11),
                        ],
                      ),
                    ),
                    ShimmerBone(width: 60, height: 24, radius: AppRadius.pill),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ShimmerBone(height: 8, radius: AppRadius.pill),
              ],
            ),
          ),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt.withOpacity(0.4),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.lg)),
            ),
          ),
        ],
      ),
    );
  }
}
