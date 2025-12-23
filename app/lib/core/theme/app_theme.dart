// TogetherLog - Application Theme (V1.1)
// Implements design_theme_v1.md specifications
// This theme applies to all UI OUTSIDE Smart Page rendering

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TogetherLog Design System Colors
/// Based on design_theme_v1.md V1.1
class AppColors {
  AppColors._();

  // === Core Palette ===
  static const Color carbonBlack = Color(0xFF1D1E20);
  static const Color darkWalnut = Color(0xFF592611);
  static const Color oliveWood = Color(0xFF785D3A);
  static const Color softApricot = Color(0xFFFCDCB5);
  static const Color antiqueWhite = Color(0xFFFDF5E6);

  // === Status Colors (V1.1) ===
  static const Color successMuted = Color(0xFF6F8F7A);
  static const Color infoMuted = Color(0xFF6F7F8F);
  static const Color errorMuted = Color(0xFF9A5A5A);

  // === Log Type Icon Colors (V1.1) ===
  static const Color logTypeCouple = Color(0xFFB86A7C);
  static const Color logTypeFriends = Color(0xFF6F86A8);
  static const Color logTypeFamily = Color(0xFF8A6FA8);

  // === Shadow Color (also defined in AppShadows for const access) ===
  static const Color shadowBase = Color(0x2E785D3A); // oliveWood @ 18%

  // === Derived Colors with Opacity ===
  static Color get secondaryText => oliveWood.withValues(alpha: 0.8);
  static Color get hintText => oliveWood.withValues(alpha: 0.5);
  static Color get helperText => oliveWood.withValues(alpha: 0.6);
  static Color get disabledText => oliveWood.withValues(alpha: 0.5);
  static Color get inactiveIcon => oliveWood.withValues(alpha: 0.7);
  static Color get disabledIcon => oliveWood.withValues(alpha: 0.4);
  static Color get emptyStateIcon => oliveWood.withValues(alpha: 0.4);
  static Color get divider => oliveWood.withValues(alpha: 0.2);
  static Color get inputBorder => oliveWood.withValues(alpha: 0.3);
  static Color get disabledBorder => oliveWood.withValues(alpha: 0.2);
  static Color get disabledBackground => oliveWood.withValues(alpha: 0.2);
  static Color get disabledChipBackground => softApricot.withValues(alpha: 0.4);

  // === Interaction State Overlays (V1.1) ===
  static Color get hoverOverlay => softApricot.withValues(alpha: 0.08);
  static Color get pressedOverlay => softApricot.withValues(alpha: 0.12);
  static Color get focusOverlay => softApricot.withValues(alpha: 0.10);
}

/// TogetherLog Spacing System
/// Based on 8dp base unit
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Page padding
  static const double pagePaddingMobile = 16;
  static const double pagePaddingDesktop = 24;
}

/// TogetherLog Border Radius
/// Based on Design Tokens.md
class AppRadius {
  AppRadius._();

  static const double rSm = 6;   // Buttons, inputs, chips
  static const double rMd = 10;  // Cards, icon containers
  static const double rLg = 16;  // Sheets, dialogs
  static const double rFull = 999; // Only when explicitly circular
}

/// TogetherLog Icon Sizes (V1.1)
class AppIconSize {
  AppIconSize._();

  static const double small = 20;
  static const double standard = 24;
  static const double large = 48;
  static const double extraLarge = 64;
}

/// TogetherLog Animation Durations (V1.1)
class AppDurations {
  AppDurations._();

  static const Duration buttonPress = Duration(milliseconds: 120);
  static const Duration hover = Duration(milliseconds: 150);
  static const Duration pageTransition = Duration(milliseconds: 220);
  static const Duration dialogEnter = Duration(milliseconds: 240);
  static const Duration bottomSheetEnter = Duration(milliseconds: 280);
}

/// TogetherLog Elevation Tokens
/// Based on Design Tokens.md semantic elevation levels
class AppElevation {
  AppElevation._();

  static const double e0 = 0;  // Background (no shadow)
  static const double e1 = 1;  // Cards
  static const double e2 = 2;  // Icon containers
  static const double e3 = 3;  // FAB
  static const double e4 = 4;  // Dialogs/overlays
}

/// TogetherLog Elevation Shadows (V1.1)
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: shadowBase,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: shadowBase,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: shadowBase,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> elevation6 = [
    BoxShadow(
      color: shadowBase,
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  // Shadow base color needs to be accessible
  static const Color shadowBase = Color(0x2E785D3A); // oliveWood @ 18%
}

/// TogetherLog Theme Builder
class AppTheme {
  AppTheme._();

  /// Get the main application theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // === Color Scheme ===
      colorScheme: const ColorScheme.light(
        primary: AppColors.darkWalnut,
        onPrimary: AppColors.antiqueWhite,
        secondary: AppColors.oliveWood,
        onSecondary: AppColors.antiqueWhite,
        surface: AppColors.antiqueWhite,
        onSurface: AppColors.carbonBlack,
        error: AppColors.errorMuted,
        onError: AppColors.antiqueWhite,
      ),

      // === Scaffold ===
      scaffoldBackgroundColor: AppColors.antiqueWhite,

      // === Typography ===
      textTheme: _buildTextTheme(),

      // === AppBar ===
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.antiqueWhite,
        foregroundColor: AppColors.carbonBlack,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.shadowBase,
        centerTitle: false, // Left-aligned per V1.1
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.carbonBlack,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.carbonBlack,
          size: AppIconSize.standard,
        ),
      ),

      // === Cards ===
      cardTheme: CardThemeData(
        color: Colors.white, // Elevated content surface above canvas
        elevation: 2,
        shadowColor: AppColors.shadowBase,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.rMd),
        ),
        margin: EdgeInsets.zero,
      ),

      // === Elevated Button (Primary) ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkWalnut,
          foregroundColor: AppColors.antiqueWhite,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.disabledText,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.rSm),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          animationDuration: AppDurations.buttonPress,
        ),
      ),

      // === Filled Button (Primary) ===
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkWalnut,
          foregroundColor: AppColors.antiqueWhite,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.disabledText,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.rSm),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // === Outlined Button (Secondary) ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.oliveWood,
          disabledForegroundColor: AppColors.disabledText,
          side: const BorderSide(color: AppColors.oliveWood),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.rSm),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.hoverOverlay;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.pressedOverlay;
            }
            return null;
          }),
        ),
      ),

      // === Text Button ===
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkWalnut,
          disabledForegroundColor: AppColors.disabledText,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.hoverOverlay;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.pressedOverlay;
            }
            return null;
          }),
        ),
      ),

      // === Floating Action Button ===
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkWalnut,
        foregroundColor: AppColors.antiqueWhite,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.rSm),
        ),
        extendedTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // === Input Decoration ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.antiqueWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.rSm),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.rSm),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.rSm),
          borderSide: const BorderSide(color: AppColors.darkWalnut, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.rSm),
          borderSide: const BorderSide(color: AppColors.errorMuted),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.rSm),
          borderSide: const BorderSide(color: AppColors.errorMuted, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.rSm),
          borderSide: BorderSide(color: AppColors.disabledBorder),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.hintText,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.secondaryText,
        ),
        helperStyle: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.helperText,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.errorMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
      ),

      // === Chip Theme ===
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.softApricot,
        selectedColor: AppColors.darkWalnut,
        disabledColor: AppColors.disabledChipBackground,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.carbonBlack,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.antiqueWhite,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.rFull),
        ),
      ),


      // === Divider ===
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.md,
      ),

      // === Dialog ===
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.antiqueWhite,
        elevation: 4,
        shadowColor: AppColors.shadowBase,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.rLg)),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.carbonBlack,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.carbonBlack,
        ),
      ),

      // === Bottom Sheet ===
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.antiqueWhite,
        elevation: 6,
        shadowColor: AppColors.shadowBase,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.rLg),
          ),
        ),
      ),

      // === Snackbar ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.carbonBlack,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.antiqueWhite,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.rSm)),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // === List Tile ===
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.carbonBlack,
        textColor: AppColors.carbonBlack,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // === Icon Theme ===
      iconTheme: const IconThemeData(
        color: AppColors.carbonBlack,
        size: AppIconSize.standard,
      ),

      // === Progress Indicator ===
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkWalnut,
        linearTrackColor: AppColors.softApricot,
        circularTrackColor: AppColors.softApricot,
      ),

      // === Switch ===
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkWalnut;
          }
          return AppColors.oliveWood;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.softApricot;
          }
          return AppColors.inputBorder;
        }),
      ),

      // === Checkbox ===
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkWalnut;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.antiqueWhite),
        side: const BorderSide(color: AppColors.oliveWood, width: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),

      // === Radio ===
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkWalnut;
          }
          return AppColors.oliveWood;
        }),
      ),

      // === Tab Bar ===
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.darkWalnut,
        unselectedLabelColor: AppColors.secondaryText,
        indicatorColor: AppColors.darkWalnut,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // === Focus ===
      focusColor: AppColors.focusOverlay,
      hoverColor: AppColors.hoverOverlay,
      splashColor: AppColors.pressedOverlay,
      highlightColor: AppColors.pressedOverlay,

      // === Page Transitions ===
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Build the text theme with Google Fonts
  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display styles - Inter only per Typography.md
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.carbonBlack,
        height: 1.4,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.carbonBlack,
        height: 1.4,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.carbonBlack,
        height: 1.4,
      ),

      // Headline styles - Inter only per Typography.md
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.carbonBlack,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.carbonBlack,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.carbonBlack,
        height: 1.4,
      ),

      // Title styles - Inter for section headers
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.carbonBlack,
        height: 1.5,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.carbonBlack,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.carbonBlack,
        height: 1.5,
      ),

      // Body styles - Inter
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.carbonBlack,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.carbonBlack,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
        height: 1.5,
      ),

      // Label styles - Inter
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.carbonBlack,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.carbonBlack,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
        height: 1.4,
      ),
    );
  }
}

/// Extension for getting log type colors
extension LogTypeColors on String {
  Color get logTypeColor {
    switch (toLowerCase()) {
      case 'couple':
        return AppColors.logTypeCouple;
      case 'friends':
        return AppColors.logTypeFriends;
      case 'family':
        return AppColors.logTypeFamily;
      default:
        return AppColors.oliveWood;
    }
  }
}
