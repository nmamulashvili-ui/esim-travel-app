import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
//  Design Tokens — the single source of truth for every
//  spacing value, color, shadow, and gradient in the app.
// ═══════════════════════════════════════════════════════════

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;

  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets screenAll = EdgeInsets.all(xl);
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;

  static BorderRadius smAll = BorderRadius.circular(sm);
  static BorderRadius mdAll = BorderRadius.circular(md);
  static BorderRadius lgAll = BorderRadius.circular(lg);
  static BorderRadius xlAll = BorderRadius.circular(xl);
  static BorderRadius xxlAll = BorderRadius.circular(xxl);
  static BorderRadius pillAll = BorderRadius.circular(pill);
}

abstract final class AppColors {
  // ── Brand — deep teal to cyan gradient family ──────────
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF5EEAD4);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryDeep = Color(0xFF134E4A);
  static const Color accent = Color(0xFF06B6D4);         // cyan-500
  static const Color accentLight = Color(0xFFCFFAFE);    // cyan-50

  // ── Neutrals ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);    // slate-900
  static const Color textSecondary = Color(0xFF64748B);  // slate-500
  static const Color textTertiary = Color(0xFF94A3B8);   // slate-400
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);     // slate-50
  static const Color backgroundAlt = Color(0xFFF1F5F9);  // slate-100
  static const Color border = Color(0xFFE2E8F0);         // slate-200
  static const Color divider = Color(0xFFF1F5F9);        // slate-100

  // ── Semantic ───────────────────────────────────────────
  static const Color success = Color(0xFF10B981);        // emerald-500
  static const Color successLight = Color(0xFFD1FAE5);   // emerald-100
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
}

abstract final class AppGradients {
  static const LinearGradient primaryHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
  );

  static const LinearGradient cardShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCCFBF1), Color(0xFFE0F2FE)],
  );

  static const LinearGradient accentCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
  );
}

abstract final class AppShadows {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get colored => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.18),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

abstract final class AppIconSize {
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 28;
  static const double xxl = 32;
}
