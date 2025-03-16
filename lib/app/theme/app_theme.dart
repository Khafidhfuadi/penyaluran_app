import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama aplikasi
  static const Color primaryColor = Color(0xFF2E5077);
  static const Color secondaryColor = Color(0xFF5882B1);
  static const Color accentColor = Color(0xFF4A6D8C);

  // Warna untuk status
  static const Color verifiedColor =
      Color(0xFF00C853); // Hijau yang lebih terang dan kontras
  static const Color processedColor =
      Color(0xFFFF9800); // Oranye yang lebih terang
  static const Color rejectedColor =
      Color(0xFFD32F2F); // Merah yang lebih gelap dan kontras
  static const Color scheduledColor =
      Color(0xFF1976D2); // Biru yang lebih terang
  static const Color completedColor =
      Color(0xFF4527A0); // Ungu yang lebih gelap dan kontras

  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color errorColor = Colors.red;
  static const Color infoColor = Colors.blue;

  // Gradient utama aplikasi
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E5077), Color(0xFF5882B1)],
    transform: GradientRotation(96.93 * 3.14159 / 180),
  );

  // Tema terang
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'DMSans',

    // Skema warna
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryColor),
    ),

    // Tombol
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      prefixIconColor: primaryColor,
      floatingLabelStyle: const TextStyle(color: primaryColor),
    ),

    // Card
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // Tema gelap (jika diperlukan)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'DMSans',
    brightness: Brightness.dark,

    // Skema warna
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      brightness: Brightness.dark,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Tombol
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
      prefixIconColor: secondaryColor,
      floatingLabelStyle: const TextStyle(color: secondaryColor),
    ),

    // Card
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF1E1E1E),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: secondaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
