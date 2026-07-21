import 'package:flutter/material.dart';

// Define an abstract class for the color palette
abstract class ColorPalette {
  Color get rosewater;
  Color get flamingo;
  Color get pink;
  Color get mauve;
  Color get red;
  Color get maroon;
  Color get peach;
  Color get yellow;
  Color get green;
  Color get teal;
  Color get sky;
  Color get sapphire;
  Color get blue;
  Color get lavender;
  Color get text;
  Color get subtext1;
  Color get subtext0;
  Color get overlay2;
  Color get overlay1;
  Color get overlay0;
  Color get surface2;
  Color get surface1;
  Color get surface0;
  Color get base;
  Color get mantle;
  Color get crust;
}

// Implement concrete color palettes
class MochaPalette implements ColorPalette {
  const MochaPalette();

  @override
  Color get rosewater => const Color(0xFFF5E0DC);
  @override
  Color get flamingo => const Color(0xFFF2CDCD);
  @override
  Color get pink => const Color(0xFFF5C2E7);
  @override
  Color get mauve => const Color(0xFFCBA6F7);
  @override
  Color get red => const Color(0xFFF38BA8);
  @override
  Color get maroon => const Color(0xFFEBA0AC);
  @override
  Color get peach => const Color(0xFFFAB387);
  @override
  Color get yellow => const Color(0xFFF9E2AF);
  @override
  Color get green => const Color(0xFFA6E3A1);
  @override
  Color get teal => const Color(0xFF94E2D5);
  @override
  Color get sky => const Color(0xFF89DCEB);
  @override
  Color get sapphire => const Color(0xFF74C7EC);
  @override
  Color get blue => const Color(0xFF89B4FA);
  @override
  Color get lavender => const Color(0xFFB4BEFE);
  @override
  Color get text => const Color(0xFFCDD6F4);
  @override
  Color get subtext1 => const Color(0xFFBAC2DE);
  @override
  Color get subtext0 => const Color(0xFFA6ADC8);
  @override
  Color get overlay2 => const Color(0xFF9399B2);
  @override
  Color get overlay1 => const Color(0xFF7F849C);
  @override
  Color get overlay0 => const Color(0xFF6C7086);
  @override
  Color get surface2 => const Color(0xFF585B70);
  @override
  Color get surface1 => const Color(0xFF45475A);
  @override
  Color get surface0 => const Color(0xFF313244);
  @override
  Color get base => const Color(0xFF1E1E2E);
  @override
  Color get mantle => const Color(0xFF181825);
  @override
  Color get crust => const Color(0xFF11111B);
}

class LattePalette implements ColorPalette {
  const LattePalette();

  @override
  Color get rosewater => const Color(0xFFDC8A78);
  @override
  Color get flamingo => const Color(0xFFDD7878);
  @override
  Color get pink => const Color(0xFFEA76CB);
  @override
  Color get mauve => const Color(0xFF8839EF);
  @override
  Color get red => const Color(0xFFD20F39);
  @override
  Color get maroon => const Color(0xFFE64553);
  @override
  Color get peach => const Color(0xFFFE640B);
  @override
  Color get yellow => const Color(0xFFDF8E1D);
  @override
  Color get green => const Color(0xFF40A02B);
  @override
  Color get teal => const Color(0xFF179299);
  @override
  Color get sky => const Color(0xFF04A5E5);
  @override
  Color get sapphire => const Color(0xFF209FB5);
  @override
  Color get blue => const Color(0xFF1E66F5);
  @override
  Color get lavender => const Color(0xFF7287FD);
  @override
  Color get text => const Color(0xFF4C4F69);
  @override
  Color get subtext1 => const Color(0xFF5C5F77);
  @override
  Color get subtext0 => const Color(0xFF6C6F85);
  @override
  Color get overlay2 => const Color(0xFF7C7F93);
  @override
  Color get overlay1 => const Color(0xFF8C8FA1);
  @override
  Color get overlay0 => const Color(0xFF9CA0B0);
  @override
  Color get surface2 => const Color(0xFFACB0BE);
  @override
  Color get surface1 => const Color(0xFFBCC0CC);
  @override
  Color get surface0 => const Color(0xFFCCD0DA);
  @override
  Color get base => const Color(0xFFEFF1F5);
  @override
  Color get mantle => const Color(0xFFE6E9EF);
  @override
  Color get crust => const Color(0xFFDCE0E8);
}

// Theme creator class
class ThemeCreator {
  static ThemeData createTheme(ColorPalette palette, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      primaryColor:
          brightness == Brightness.dark ? palette.yellow : palette.sky,
      scaffoldBackgroundColor: palette.base,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.base,
        foregroundColor: palette.text,
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: brightness == Brightness.dark ? palette.mauve : palette.sky,
        secondary: brightness == Brightness.dark ? palette.pink : palette.text,
        surface: palette.base,
        error: palette.red,
        onPrimary: palette.base,
        onSecondary: palette.mantle,
        onSurface: palette.text,
        onError: palette.crust,
      ),
      cardTheme: CardTheme(
        color: palette.mantle,
        shadowColor: brightness == Brightness.dark
            ? Colors.black
            : palette.text.withOpacity(0.4),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: palette.text),
        titleMedium: TextStyle(color: palette.text),
        headlineMedium: TextStyle(color: palette.text),
        headlineSmall:
            TextStyle(color: palette.text, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: palette.text),
        bodyMedium: TextStyle(color: palette.subtext1),
      ),
      splashColor: (brightness == Brightness.dark ? palette.mauve : palette.sky)
          .withOpacity(0.3),
      highlightColor: Colors.transparent,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              brightness == Brightness.dark ? palette.mauve : palette.sky,
          foregroundColor: palette.base,
        ),
      ),
      shadowColor: brightness == Brightness.dark
          ? Colors.black.withOpacity(0.5)
          : palette.text.withOpacity(0.4),
    );
  }
}

// App theme class
class AppTheme {
  static final darkTheme =
      ThemeCreator.createTheme(const MochaPalette(), Brightness.dark);
  static final lightTheme =
      ThemeCreator.createTheme(const LattePalette(), Brightness.light);
}
