import 'package:flutter/material.dart';

import '../config/design_tokens.dart';
import 'app_button.dart';

/// Animated empty-state placeholder. Fades + scales in on mount.
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _fade = Tween(begin: 0.0, end: 1.0).animate(curve);
    _scale = Tween(begin: 0.92, end: 1.0).animate(curve);
    _slide = Tween(
      begin: const Offset(0, 16),
      end: Offset.zero,
    ).animate(curve);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: _slide.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Opacity(opacity: _fade.value, child: child),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing icon container
              _PulsingIcon(icon: widget.icon),
              const SizedBox(height: AppSpacing.xxl),
              Text(widget.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (widget.actionLabel != null && widget.onAction != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                AppButton.secondary(
                  label: widget.actionLabel!,
                  expand: false,
                  onPressed: widget.onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon that gently pulses on loop to draw attention.
class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  const _PulsingIcon({required this.icon});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          gradient: AppGradients.cardShimmer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(widget.icon, size: 38, color: AppColors.primary),
      ),
    );
  }
}
