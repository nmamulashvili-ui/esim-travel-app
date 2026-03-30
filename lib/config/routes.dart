import 'package:flutter/material.dart';

import '../models/data_bundle.dart';
import '../models/esim_plan.dart';
import '../models/user_esim.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/esim_detail/esim_detail_screen.dart';
import '../screens/plan_detail/plan_detail_screen.dart';
import '../screens/shell/app_shell.dart';

abstract final class AppRoutes {
  static const String shell = '/';
  static const String planDetail = '/plan-detail';
  static const String checkout = '/checkout';
  static const String esimDetail = '/esim-detail';
}

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.shell:
      return MaterialPageRoute(
        builder: (_) => const AppShell(),
        settings: settings,
      );

    case AppRoutes.planDetail:
      final plan = settings.arguments as EsimPlan;
      return _SlideUpRoute(
        page: PlanDetailScreen(plan: plan),
        settings: settings,
      );

    case AppRoutes.checkout:
      final bundle = settings.arguments as DataBundle;
      return _SlideUpRoute(
        page: CheckoutScreen(bundle: bundle),
        settings: settings,
      );

    case AppRoutes.esimDetail:
      final esim = settings.arguments as UserEsim;
      return _FadeScaleRoute(
        page: EsimDetailScreen(esim: esim),
        settings: settings,
      );

    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Route "${settings.name}" not found')),
        ),
      );
  }
}

// ═════════════════════════════════════════════════════════
//  Custom page transitions
// ═════════════════════════════════════════════════════════

/// Slides the new page up from the bottom with a subtle fade.
class _SlideUpRoute extends PageRouteBuilder {
  final Widget page;

  _SlideUpRoute({required this.page, required RouteSettings settings})
      : super(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Fades and scales the page in from slightly smaller.
class _FadeScaleRoute extends PageRouteBuilder {
  final Widget page;

  _FadeScaleRoute({required this.page, required RouteSettings settings})
      : super(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        );
}
