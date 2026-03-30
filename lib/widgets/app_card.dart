import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/design_tokens.dart';

/// Themed card with press-down animation, optional shadow, and gradient.
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final bool elevated;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevated = false,
    this.gradient,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _pressCtrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _pressCtrl.reverse();
  }

  void _onTapCancel() {
    _pressCtrl.reverse();
  }

  void _onTap() {
    if (widget.onTap != null) {
      HapticFeedback.lightImpact();
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = widget.padding ?? const EdgeInsets.all(AppSpacing.lg);

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: Container(
          margin: widget.margin ?? EdgeInsets.zero,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient != null ? null : (widget.color ?? AppColors.surface),
            borderRadius: AppRadius.lgAll,
            border: widget.gradient != null
                ? null
                : Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: widget.elevated
                ? (widget.gradient != null ? AppShadows.colored : AppShadows.sm)
                : null,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.lgAll,
            child: Padding(padding: resolvedPadding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
