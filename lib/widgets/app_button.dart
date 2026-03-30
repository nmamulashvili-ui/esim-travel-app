import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/design_tokens.dart';

enum AppButtonVariant { primary, secondary, outline, text }
enum AppButtonSize { sm, md, lg }

/// Unified button with press-down animation, haptic feedback, and loading state.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.outline;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.text;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.965).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _enabled =>
      !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final double height = switch (widget.size) {
      AppButtonSize.sm => 36,
      AppButtonSize.md => 44,
      AppButtonSize.lg => 52,
    };
    final double fontSize = switch (widget.size) {
      AppButtonSize.sm => 13,
      AppButtonSize.md => 14,
      AppButtonSize.lg => 15,
    };
    final edgePadding = switch (widget.size) {
      AppButtonSize.sm =>
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      AppButtonSize.md =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      AppButtonSize.lg =>
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    };

    final innerChild = widget.isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: widget.variant == AppButtonVariant.primary
                  ? Colors.white
                  : AppColors.primary,
            ),
          )
        : Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: fontSize + 3),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label),
            ],
          );

    final shape = RoundedRectangleBorder(borderRadius: AppRadius.lgAll);
    final minSize =
        widget.expand ? Size.fromHeight(height) : Size(0, height);
    final style = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600);

    Widget button = switch (widget.variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: _enabled ? () {} : null,
          style: FilledButton.styleFrom(
            minimumSize: minSize,
            padding: edgePadding,
            textStyle: style,
            shape: shape,
          ),
          child: innerChild,
        ),
      AppButtonVariant.secondary => FilledButton.tonal(
          onPressed: _enabled ? () {} : null,
          style: FilledButton.styleFrom(
            minimumSize: minSize,
            padding: edgePadding,
            textStyle: style,
            shape: shape,
          ),
          child: innerChild,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: _enabled ? () {} : null,
          style: OutlinedButton.styleFrom(
            minimumSize: minSize,
            padding: edgePadding,
            textStyle: style,
            shape: shape,
          ),
          child: innerChild,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: _enabled ? () {} : null,
          style: TextButton.styleFrom(
            minimumSize: minSize,
            padding: edgePadding,
            textStyle: style,
            shape: shape,
          ),
          child: innerChild,
        ),
    };

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _enabled ? (_) => _pressCtrl.forward() : null,
        onTapUp: _enabled
            ? (_) {
                _pressCtrl.reverse();
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: _enabled ? () => _pressCtrl.reverse() : null,
        child: AbsorbPointer(child: button),
      ),
    );
  }
}
