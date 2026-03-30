import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/routes.dart';
import '../../config/utils.dart';
import '../../models/data_bundle.dart';
import '../../models/order.dart';
import '../../models/user_esim.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/info_row.dart';

enum _CheckoutStep { review, processing, success, failed }

class CheckoutScreen extends StatefulWidget {
  final DataBundle bundle;
  const CheckoutScreen({super.key, required this.bundle});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  _CheckoutStep _step = _CheckoutStep.review;
  Order? _order;
  String? _errorMessage;

  // Progress animation for the processing step.
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  // ── Purchase flow ──────────────────────────────────────
  Future<void> _startPurchase() async {
    setState(() => _step = _CheckoutStep.processing);
    _progressCtrl.forward();

    try {
      final api = context.read<ApiService>();
      final order = await api.createOrder(bundle: widget.bundle);

      // Ensure the progress animation finishes for visual polish.
      if (_progressCtrl.isAnimating) {
        await _progressCtrl.forward();
      }
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      setState(() {
        _order = order;
        _step = _CheckoutStep.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _step = _CheckoutStep.failed;
      });
    }
  }

  void _viewEsim() {
    final o = _order!;
    final esim = UserEsim(
      id: o.id,
      country: o.region,
      countryCode: _regionToCode(o.region),
      operator: _regionToOperator(o.region),
      dataAmount: o.dataAmount,
      dataUsed: '0 GB',
      totalDays: o.validityDays,
      daysLeft: o.validityDays,
      isActive: true,
      iccid: o.iccid ?? '',
      purchasedAt: o.createdAt,
    );

    // Pop the entire checkout stack and push eSIM detail.
    Navigator.of(context).popUntil((r) => r.settings.name == AppRoutes.shell);
    Navigator.of(context).pushNamed(AppRoutes.esimDetail, arguments: esim);
  }

  String _regionToCode(String r) => switch (r) {
        'Turkey' => 'TR',
        'Europe' => 'EU',
        'USA' => 'US',
        'Asia' => 'AS',
        'Global' => 'GL',
        _ => 'XX',
      };
  String _regionToOperator(String r) => switch (r) {
        'Turkey' => 'Turkcell',
        'Europe' => 'Multi-carrier EU',
        'USA' => 'T-Mobile',
        'Asia' => 'Multi-carrier Asia',
        'Global' => 'Global eSIM',
        _ => 'eSIM Provider',
      };

  // ── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _step == _CheckoutStep.review
          ? AppBar(title: const Text('Checkout'))
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        child: switch (_step) {
          _CheckoutStep.review => _ReviewView(
              key: const ValueKey('review'),
              bundle: widget.bundle,
            ),
          _CheckoutStep.processing => _ProcessingView(
              key: const ValueKey('processing'),
              progress: _progressAnim,
            ),
          _CheckoutStep.success => _SuccessView(
              key: const ValueKey('success'),
              order: _order!,
              bundle: widget.bundle,
              onViewEsim: _viewEsim,
            ),
          _CheckoutStep.failed => _FailedView(
              key: const ValueKey('failed'),
              message: _errorMessage ?? 'Something went wrong',
              onRetry: () {
                _progressCtrl.reset();
                _startPurchase();
              },
            ),
        },
      ),
      bottomNavigationBar: _step == _CheckoutStep.review
          ? _PayBar(
              bundle: widget.bundle,
              onPay: _startPurchase,
            )
          : null,
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Step 1 — Review order
// ═════════════════════════════════════════════════════════

class _ReviewView extends StatelessWidget {
  final DataBundle bundle;
  const _ReviewView({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        // ── Order summary ──────────────────────────────
        AppCard(
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardShimmer,
                      borderRadius: AppRadius.mdAll,
                    ),
                    alignment: Alignment.center,
                    child: Text(flagEmoji(bundle.regionCode),
                        style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bundle.region,
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text('${bundle.dataAmount} · ${bundle.validityDays} days',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1, color: AppColors.divider),
              InfoRow(
                icon: Icons.cloud_download_outlined,
                label: 'Data',
                value: bundle.dataAmount,
              ),
              const Divider(height: 1, color: AppColors.divider),
              InfoRow(
                icon: Icons.schedule_outlined,
                label: 'Validity',
                value: '${bundle.validityDays} days',
              ),
              if (bundle.features.isNotEmpty) ...[
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: bundle.features
                      .map((f) => Chip(
                            avatar: const Icon(Icons.check_circle,
                                size: 14, color: AppColors.success),
                            label: Text(f),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Payment method ─────────────────────────────
        const SectionHeader(title: 'Payment method'),
        AppCard(
          onTap: () {},
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundAlt,
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(Icons.credit_card_rounded,
                    color: AppColors.textSecondary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visa •••• 4242',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text('Expires 12/27',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.check_circle,
                  size: 20, color: AppColors.success),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Price breakdown ────────────────────────────
        const SectionHeader(title: 'Price breakdown'),
        AppCard(
          child: Column(
            children: [
              _PriceRow(
                  label: 'eSIM plan',
                  value: '\$${bundle.priceUsd.toStringAsFixed(2)}'),
              const SizedBox(height: AppSpacing.sm),
              const _PriceRow(label: 'Service fee', value: '\$0.00'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(height: 1),
              ),
              _PriceRow(
                label: 'Total',
                value: '\$${bundle.priceUsd.toStringAsFixed(2)}',
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Step 2 — Processing payment
// ═════════════════════════════════════════════════════════

class _ProcessingView extends StatelessWidget {
  final Animation<double> progress;
  const _ProcessingView({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated ring
              SizedBox(
                width: 100,
                height: 100,
                child: AnimatedBuilder(
                  animation: progress,
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: progress.value,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          backgroundColor: AppColors.backgroundAlt,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary),
                        ),
                      ),
                      Text(
                        '${(progress.value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text('Processing payment',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Please wait while we set up your eSIM…',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),

              // Step indicators
              const SizedBox(height: AppSpacing.xxxxl),
              AnimatedBuilder(
                animation: progress,
                builder: (_, __) => Column(
                  children: [
                    _StepRow(
                      label: 'Verifying payment',
                      isDone: progress.value > 0.35,
                      isActive: progress.value <= 0.35,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _StepRow(
                      label: 'Creating eSIM profile',
                      isDone: progress.value > 0.7,
                      isActive:
                          progress.value > 0.35 && progress.value <= 0.7,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _StepRow(
                      label: 'Generating QR code',
                      isDone: progress.value >= 1.0,
                      isActive: progress.value > 0.7 && progress.value < 1.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isActive;

  const _StepRow({
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.textTertiary;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.successLight
                : isActive
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.backgroundAlt,
            shape: BoxShape.circle,
          ),
          child: isDone
              ? const Icon(Icons.check_rounded,
                  size: 16, color: AppColors.success)
              : isActive
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(Icons.circle_outlined, size: 14, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isDone || isActive ? FontWeight.w600 : FontWeight.w400,
            color: isDone || isActive
                ? AppColors.textPrimary
                : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Step 3 — Success
// ═════════════════════════════════════════════════════════

class _SuccessView extends StatefulWidget {
  final Order order;
  final DataBundle bundle;
  final VoidCallback onViewEsim;

  const _SuccessView({
    super.key,
    required this.order,
    required this.bundle,
    required this.onViewEsim,
  });

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _bounceCtrl,
      curve: Curves.elasticOut,
    );
    _bounceCtrl.forward();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.order;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxxl),

            // Check animation
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  gradient: AppGradients.accentCard,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text('Purchase complete!',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your eSIM is ready to install',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Order summary card
            AppCard(
              elevated: true,
              child: Column(
                children: [
                  _SummaryRow(label: 'Order', value: order.id),
                  const Divider(height: 20, color: AppColors.divider),
                  _SummaryRow(label: 'Region', value: order.region),
                  const Divider(height: 20, color: AppColors.divider),
                  _SummaryRow(label: 'Data', value: order.dataAmount),
                  const Divider(height: 20, color: AppColors.divider),
                  _SummaryRow(
                      label: 'Validity',
                      value: '${order.validityDays} days'),
                  const Divider(height: 20, color: AppColors.divider),
                  _SummaryRow(
                    label: 'Total paid',
                    value: '\$${order.totalUsd.toStringAsFixed(2)}',
                    bold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // CTA
            AppButton(
              label: 'View My eSIM',
              icon: Icons.sim_card_outlined,
              onPressed: widget.onViewEsim,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.text(
              label: 'Back to Home',
              onPressed: () => Navigator.of(context)
                  .popUntil((r) => r.settings.name == AppRoutes.shell),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _SummaryRow(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: bold
              ? theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)
              : theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Step 4 — Failed (retry)
// ═════════════════════════════════════════════════════════

class _FailedView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailedView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 40, color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Payment failed', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.outline(
                label: 'Go Back',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Bottom pay bar
// ═════════════════════════════════════════════════════════

class _PayBar extends StatelessWidget {
  final DataBundle bundle;
  final VoidCallback onPay;
  const _PayBar({required this.bundle, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          child: AppButton(
            label: 'Pay \$${bundle.priceUsd.toStringAsFixed(2)}',
            icon: Icons.lock_outline,
            onPressed: onPay,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  Shared
// ═════════════════════════════════════════════════════════

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _PriceRow(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? theme.textTheme.titleSmall
                : theme.textTheme.bodyMedium),
        Text(value,
            style: bold
                ? theme.textTheme.titleMedium
                    ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)
                : theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
