import 'package:flutter/material.dart';

const Color black = Color.fromARGB(255, 18, 18, 18);
const Color white = Color.fromARGB(255, 255, 255, 255);
const Color grey = Color.fromARGB(255, 194, 194, 194);
const Color darkGreen = Color.fromARGB(255, 25, 111, 93);
const Color green = Color.fromARGB(255, 71, 222, 86);
const Color lime = Color.fromARGB(255, 161, 234, 93);
const Color red = Color.fromARGB(255, 203, 93, 78);

// App Color Palette
class AppColors {
  static const Color primary = Color(0xFF006D42); // Example: dark green
  static const Color secondary = Color(0xFF5AD689); // Example: light green
  static const Color accent = Color(0xFFB8FF7B); // Example: accent green
  static const Color background =
      Color(0xFFF2F2F2); // Example: light background
  static const Color backgroundSecondary = Color(0xFF0B2938);
  static const Color surface = Color(0xFFFFFFFF); // white
  static const Color error = Color(0xFFCB5D4E); // red
  static const Color onPrimary = Color(0xFFFFFFFF); // white
  static const Color onSecondary = Color(0xFF121212); // black
  static const Color onBackground = Color(0xFF121212); // black
  static const Color onSurface = Color(0xFF121212); // black
  static const Color onError = Color(0xFFFFFFFF); // white
  static const Color darkGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color blue = Color(0xFF2196F3);
  static const Color transparent = Colors.transparent;
}

// Font Sizes
class AppFontSizes {
  static const double headline = 26;
  static const double title = 20;
  static const double subtitle = 16;
  static const double body = 14;
  static const double small = 12;
}

// Font Weights
class AppFontWeights {
  static const FontWeight bold = FontWeight.bold;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight extraBold = FontWeight.w700;
}

// Common SizedBox Heights
class AppGaps {
  static const double gap4 = 4;
  static const double gap6 = 6;
  static const double gap8 = 8;
  static const double gap10 = 10;
  static const double gap12 = 12;
  static const double gap16 = 16;
  static const double gap20 = 20;
  static const double gap24 = 24;
  static const double gap32 = 32;
  static const double gap40 = 40;
}

// Common Paddings
class AppPaddings {
  static const EdgeInsets all8 = EdgeInsets.all(8);
  static const EdgeInsets all12 = EdgeInsets.all(12);
  static const EdgeInsets all16 = EdgeInsets.all(16);
  static const EdgeInsets horizontal16 = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets vertical8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets vertical16 = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets button =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}

// Common Margins
class AppMargins {
  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets section = EdgeInsets.symmetric(vertical: 24);
}

// Common Spacing
class AppSpacing {
  static const double icon = 12;
  static const double chip = 10;
  static const double listItem = 6;
}
