import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/routes.dart';
import '../../config/utils.dart';
import '../../models/user_esim.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/stagger_list.dart';

class MyEsimsScreen extends StatefulWidget {
  const MyEsimsScreen({super.key});

  @override
  State<MyEsimsScreen> createState() => _MyEsimsScreenState();
}

class _MyEsimsScreenState extends State<MyEsimsScreen> {
  List<UserEsim> _esims = [];
  bool _loading = true;
  String? _error;
  _TabFilter _filter = _TabFilter.active;

  List<UserEsim> get _filtered => switch (_filter) {
        _TabFilter.active => _esims.where((e) => e.isActive).toList(),
        _TabFilter.expired => _esims.where((e) => !e.isActive).toList(),
        _TabFilter.all => _esims,
      };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      _esims = await api.getUserEsims();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = _esims.where((e) => e.isActive).length;
    final expiredCount = _esims.where((e) => !e.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────
          GradientHeader(
            title: 'My eSIMs',
            subtitle: '${_esims.length} plans · $activeCount active',
          ),

          // ── Tab filter ──────────────────────────────────
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xs),
              child: Row(
                children: [
                  _TabChip(
                    label: 'Active',
                    count: activeCount,
                    isSelected: _filter == _TabFilter.active,
                    onTap: () =>
                        setState(() => _filter = _TabFilter.active),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _TabChip(
                    label: 'Expired',
                    count: expiredCount,
                    isSelected: _filter == _TabFilter.expired,
                    onTap: () =>
                        setState(() => _filter = _TabFilter.expired),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _TabChip(
                    label: 'All',
                    count: _esims.length,
                    isSelected: _filter == _TabFilter.all,
                    onTap: () =>
                        setState(() => _filter = _TabFilter.all),
                  ),
                ],
              ),
            ),

          // ── List ────────────────────────────────────────
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return ShimmerLoading(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
          itemCount: 3,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, __) => const EsimCardSkeleton(),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(_error!, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            AppButton.secondary(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              expand: false,
              size: AppButtonSize.sm,
              onPressed: _load,
            ),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return EmptyState(
        icon: _filter == _TabFilter.expired
            ? Icons.history_outlined
            : Icons.sim_card_outlined,
        title: _filter == _TabFilter.expired
            ? 'No expired plans'
            : 'No active eSIMs',
        message: _filter == _TabFilter.expired
            ? 'Expired plans will appear here.'
            : 'Purchase a bundle to get started.',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) => StaggeredListItem(
          index: i,
          child: _EsimCard(esim: _filtered[i]),
        ),
      ),
    );
  }
}

enum _TabFilter { active, expired, all }

// ═════════════════════════════════════════════════════════
//  Tab filter chip
// ═════════════════════════════════════════════════════════

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected ? AppShadows.colored : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : AppColors.backgroundAlt,
                borderRadius: AppRadius.pillAll,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color:
                      isSelected ? Colors.white : AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  eSIM card
// ═════════════════════════════════════════════════════════

class _EsimCard extends StatelessWidget {
  final UserEsim esim;
  const _EsimCard({required this.esim});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = esim.usageFraction;
    final barColor = !esim.isActive
        ? AppColors.textTertiary
        : fraction > 0.9
            ? AppColors.error
            : fraction > 0.75
                ? AppColors.warning
                : AppColors.primary;

    return AppCard(
      elevated: true,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.esimDetail,
        arguments: esim,
      ),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Top section ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: Row(
              children: [
                // Flag badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: esim.isActive
                        ? AppGradients.cardShimmer
                        : null,
                    color: esim.isActive ? null : AppColors.backgroundAlt,
                    borderRadius: AppRadius.mdAll,
                  ),
                  alignment: Alignment.center,
                  child: Text(flagEmoji(esim.countryCode),
                      style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: AppSpacing.md),

                // Country + operator
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(esim.country,
                          style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(esim.operator,
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),

                // Status badge
                _StatusBadge(isActive: esim.isActive),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Data usage section ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                // Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12),
                        children: [
                          TextSpan(
                            text: esim.dataUsed,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: barColor,
                            ),
                          ),
                          const TextSpan(
                            text: ' used',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      esim.dataAmount,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Bar
                ClipRRect(
                  borderRadius: AppRadius.pillAll,
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: AppColors.backgroundAlt,
                    valueColor: AlwaysStoppedAnimation(barColor),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Remaining data text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    esim.isActive
                        ? '${esim.dataRemaining} remaining'
                        : 'No data remaining',
                    style: TextStyle(
                      fontSize: 11,
                      color: esim.isActive
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Bottom meta bar ────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt.withOpacity(0.6),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.lg)),
            ),
            child: Row(
              children: [
                // Days left
                _MetaItem(
                  icon: Icons.schedule_outlined,
                  label: esim.isActive
                      ? '${esim.daysLeft}d left'
                      : 'Expired',
                ),
                const SizedBox(width: AppSpacing.lg),

                // Expiry date
                _MetaItem(
                  icon: Icons.event_outlined,
                  label: esim.isActive
                      ? 'Expires ${esim.expiresFormatted}'
                      : 'Ended ${esim.expiresFormatted}',
                ),

                const Spacer(),

                // Arrow
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.sm,
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.primary),
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
//  Sub-widgets
// ═════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.backgroundAlt,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Expired',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
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
    );
  }
}
