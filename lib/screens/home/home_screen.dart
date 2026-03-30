import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/routes.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/plan_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/stagger_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PlanProvider>().loadPlans());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlanProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientHeader(
            title: 'eSIM Market',
            subtitle: 'Instant data plans for 190+ countries',
            trailing: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person_outline, color: Colors.white, size: 22),
            ),
          ),

          // ── Search bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
            child: TextField(
              onChanged: provider.setSearch,
              decoration: InputDecoration(
                hintText: 'Search by country…',
                prefixIcon:
                    const Icon(Icons.search_rounded, size: AppIconSize.lg),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: AppIconSize.md),
                        onPressed: provider.clearSearch,
                      )
                    : null,
              ),
            ),
          ),

          // ── Section label ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xs),
            child: Row(
              children: [
                Text(
                  provider.searchQuery.isEmpty
                      ? 'Popular destinations'
                      : 'Results',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (!provider.isLoading)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '${provider.filteredPlans.length} plans',
                      key: ValueKey(provider.filteredPlans.length),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),

          // ── Plan list ───────────────────────────────────
          Expanded(child: _buildBody(provider, theme)),
        ],
      ),
    );
  }

  Widget _buildBody(PlanProvider provider, ThemeData theme) {
    // Shimmer skeleton loading
    if (provider.isLoading) {
      return ShimmerLoading(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
              top: AppSpacing.sm, bottom: AppSpacing.xxxl),
          itemCount: 5,
          itemBuilder: (_, __) => const PlanCardSkeleton(),
        ),
      );
    }

    // Error state
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text('Something went wrong', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(provider.error!, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xl),
            AppButton.secondary(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              expand: false,
              size: AppButtonSize.sm,
              onPressed: provider.loadPlans,
            ),
          ],
        ),
      );
    }

    // Empty state
    if (provider.filteredPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text('No plans found', style: theme.textTheme.titleSmall),
          ],
        ),
      );
    }

    // Loaded — staggered list
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: provider.loadPlans,
      child: ListView.builder(
        padding: const EdgeInsets.only(
            top: AppSpacing.sm, bottom: AppSpacing.xxxl),
        itemCount: provider.filteredPlans.length,
        itemBuilder: (_, i) {
          final plan = provider.filteredPlans[i];
          return StaggeredListItem(
            index: i,
            child: PlanCard(
              plan: plan,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.planDetail,
                arguments: plan,
              ),
            ),
          );
        },
      ),
    );
  }
}
