import 'package:flutter/material.dart';

/// Wraps a child widget and animates it in with a staggered
/// slide-up + fade effect based on its [index] in a list.
///
/// Usage inside a ListView.builder:
/// ```dart
/// itemBuilder: (_, i) => StaggeredListItem(
///   index: i,
///   child: MyCard(),
/// ),
/// ```
class StaggeredListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final double slideOffset;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.slideOffset = 30,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(curve);
    _slideAnim = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(curve);

    // Stagger: each item waits a bit longer than the previous.
    final delay = Duration(milliseconds: (widget.index * 60).clamp(0, 400));
    Future.delayed(delay, () {
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: _slideAnim.value,
        child: Opacity(opacity: _fadeAnim.value, child: child),
      ),
      child: widget.child,
    );
  }
}
