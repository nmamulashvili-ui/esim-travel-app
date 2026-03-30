import 'package:flutter/material.dart';

import '../config/design_tokens.dart';
import '../config/utils.dart';
import '../models/esim_plan.dart';
import 'app_card.dart';

/// Polished plan card with flag, country info, and price badge.
class PlanCard extends StatelessWidget {
  final EsimPlan plan;
  final VoidCallback onTap;

  const PlanCard({super.key, required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      elevated: true,
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Flag circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppGradients.cardShimmer,
              borderRadius: AppRadius.lgAll,
            ),
            alignment: Alignment.center,
            child: Text(
              flagEmoji(plan.countryCode),
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Country + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.country, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _MetaChip(label: plan.dataAmount),
                    const SizedBox(width: AppSpacing.sm),
                    _MetaChip(label: '${plan.validityDays}d'),
                  ],
                ),
              ],
            ),
          ),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${plan.priceUsd.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                plan.operator,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),

          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: AppIconSize.md,
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
