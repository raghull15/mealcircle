import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MealCircle Design System
/// Centralized design constants for consistent UI across the app

// ============================================================================
// COLORS
// ============================================================================

class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF00B562);
  static const Color accentOrange = Color(0xFFFF6B35);
  
  // Background Colors
  static const Color backgroundCream = Color(0xFFFFFBF7);
  static const Color cardWhite = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textDark = Color(0xFF1C1C1C);
  static const Color textLight = Color(0xFF6B7280);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Additional Colors
  static const Color purple = Color(0xFF9333EA);
  static const Color teal = Color(0xFF14B8A6);
  static const Color indigo = Color(0xFF6366F1);
  static const Color pink = Color(0xFFEC4899);

  // Basic Utility Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textBlack = Color(0xFF000000);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color transparent = Colors.transparent;
}

// ============================================================================
// TYPOGRAPHY
// ============================================================================

class AppTypography {
  // Display Styles (Large headings)
  static TextStyle displayLarge({Color? color}) => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.textDark,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.textDark,
    letterSpacing: -0.5,
  );

  static TextStyle displaySmall({Color? color}) => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.textDark,
    letterSpacing: -0.3,
  );

  // Heading Styles
  static TextStyle headingLarge({Color? color}) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.textDark,
    letterSpacing: -0.3,
  );

  // ...existing code...

  static TextStyle headingMedium({Color? color, double? fontSize}) => GoogleFonts.poppins(
    fontSize: fontSize ?? 20,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.textDark,
    letterSpacing: -0.3,
  );

// ...existing code...

  static TextStyle headingSmall({Color? color}) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.textDark,
  );

  // Body Styles
  static TextStyle bodyLarge({Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: fontWeight ?? FontWeight.w400,
    color: color ?? AppColors.textDark,
  );

  static TextStyle bodyMedium({Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: fontWeight ?? FontWeight.w400,
    color: color ?? AppColors.textDark,
  );

  static TextStyle bodySmall({Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: fontWeight ?? FontWeight.w400,
    color: color ?? AppColors.textDark,
  );

  // Label Styles
  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textDark,
  );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textDark,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textDark,
  );

  // Caption Styles
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textLight,
  );

  static TextStyle captionSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textLight,
  );
}

// ============================================================================
// SPACING
// ============================================================================

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

// ============================================================================
// BORDER RADIUS
// ============================================================================

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 999.0;
}

// ============================================================================
// SHADOWS
// ============================================================================

class AppShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

// ============================================================================
// DECORATIONS
// ============================================================================

class AppDecorations {
  /// Card decoration with border and shadow
  static BoxDecoration card({
    Color? color,
    Color? borderColor,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.cardWhite,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: borderColor ?? AppColors.borderLight),
      boxShadow: shadows ?? AppShadows.small,
    );
  }

  /// Gradient background decoration
  static BoxDecoration gradient({
    required Color startColor,
    required Color endColor,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: begin ?? Alignment.topLeft,
        end: end ?? Alignment.bottomRight,
        colors: [startColor, endColor],
      ),
    );
  }

  /// Rounded container decoration
  static BoxDecoration rounded({
    required Color color,
    double? radius,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
    );
  }
}

// ============================================================================
// RESPONSIVE BREAKPOINTS
// ============================================================================

class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppSpacing.lg);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppSpacing.xxl);
    } else {
      return const EdgeInsets.all(AppSpacing.xxxl);
    }
  }
}

// ============================================================================
// BUTTON STYLES
// ============================================================================

class AppButtonStyles {
  /// Primary button style
  static ButtonStyle primary({Color? backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.primaryGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      elevation: 0,
    );
  }

  /// Secondary button style
  static ButtonStyle secondary({Color? borderColor}) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.textDark,
      side: BorderSide(color: borderColor ?? AppColors.borderLight),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }

  /// Text button style
  static ButtonStyle text({Color? color}) {
    return TextButton.styleFrom(
      foregroundColor: color ?? AppColors.primaryGreen,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    );
  }
}

// ============================================================================
// APP BAR STYLES
// ============================================================================

class AppBarStyles {
  /// Standard app bar with gradient
  static PreferredSizeWidget standard({
    required BuildContext context,
    required String title,
    String? subtitle,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    Color? backgroundColor,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor ?? AppColors.primaryGreen,
              (backgroundColor ?? AppColors.primaryGreen).withOpacity(0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                if (onBackPressed != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: onBackPressed,
                  ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headingMedium(color: Colors.white),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTypography.caption(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions != null) ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
