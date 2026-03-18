import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF8B2E8B);      // Purple
  static const Color primaryDark = Color(0xFF5E1B5E);  // Darker Purple for pressed states
  static const Color accent = Color(0xFFB042B0);       // Lighter Purple for highlights
  
  // Background Colors
  static const Color background = Color(0xFF121212);   // Deep Dark
  static const Color surface = Color(0xFF1E1E1E);      // Elevated surface (Cards)
  static const Color surfaceLight = Color(0xFF2A2A2A); // Elevated surface (Inputs/Inner Cards)
  
  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white54;
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);

  // Spacing & Layout
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets defaultMargin = EdgeInsets.only(bottom: 16.0);
  static const double borderRadius = 12.0;

  static String formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr == 'Full History' || dateStr == 'Other' || dateStr == '' || dateStr == 'All History') return dateStr?.toString() ?? 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      if (dateStr.toString().contains('-')) return dateStr.toString(); // already formatted or custom
      return dateStr.toString();
    }
  }

  // Text Styles
  static const TextStyle heading1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary);
  static const TextStyle heading2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary);
  static const TextStyle heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, color: textPrimary);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, color: textSecondary);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, color: textTertiary);

  // Theme Data for Material App
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto', // Or typical system font
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // We use extendBodyBehindAppBar usually
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      ),
    );
  }

  // Common UI Components

  /// A standardized background that fits behind most screens
  static Widget buildBackground(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/bgImage.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/farmland_bg.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.9),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  /// A modern text field layout
  static Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    bool readOnly = false,
    double? fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 14, color: textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: readOnly ? surfaceLight : surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: readOnly ? primary.withOpacity(0.3) : surfaceLight,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          constraints: const BoxConstraints(minHeight: 56),
          child: readOnly
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    constraints: const BoxConstraints(minHeight: 56),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        if (prefixIcon != null) ...[
                          prefixIcon,
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            controller.text.isEmpty ? (hint ?? '') : controller.text,
                            style: TextStyle(
                              color: controller.text.isEmpty ? textTertiary : textPrimary,
                              fontSize: fontSize ?? 16,
                              fontWeight: readOnly ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (suffixIcon != null) suffixIcon,
                      ],
                    ),
                  ),
                )
              : TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  style: TextStyle(color: textPrimary, fontSize: fontSize ?? 16),
                  onChanged: onChanged,
                  onTap: onTap,
                  readOnly: readOnly,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                    prefixIcon: prefixIcon,
                    suffixIcon: suffixIcon,
                  ),
                ),
        ),
      ],
    );
  }

  /// A modern dropdown field layout matching the text field
  static Widget buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    String? hint,
    double? fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 14, color: textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: surfaceLight, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          constraints: const BoxConstraints(minHeight: 56),
          alignment: Alignment.centerLeft,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: surfaceLight,
              icon: const Icon(Icons.keyboard_arrow_down, color: textSecondary),
              style: TextStyle(color: textPrimary, fontSize: fontSize ?? 16),
              hint: hint != null ? Text(hint, style: TextStyle(color: textTertiary, fontSize: fontSize ?? 14)) : null,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable Card Container
  static Widget buildCard({required Widget child, EdgeInsetsGeometry? padding, EdgeInsetsGeometry? margin}) {
    return Container(
      padding: padding ?? defaultPadding,
      margin: margin,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
