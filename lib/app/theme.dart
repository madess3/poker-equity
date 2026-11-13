import 'package:material_ui/material_ui.dart';

/// Все цвета и размеры шрифта приложения — только здесь.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface2,
    required this.muted,
    required this.line,
    required this.accentSoft,
    required this.accentText,
    required this.cardFace,
    required this.warn,
    required this.warnBg,
  });

  final Color surface2;
  final Color muted;
  final Color line;
  final Color accentSoft;
  final Color accentText;
  final Color cardFace;
  final Color warn;
  final Color warnBg;

  static const dark = AppColors(
    surface2: Color(0xFF262A31),
    muted: Color(0xFFA0A7B0),
    line: Color(0xFF3A414A),
    accentSoft: Color(0xFF1E3A2E),
    accentText: Color(0xFF7BE8B9),
    cardFace: Color(0xFFF4F5F6),
    warn: Color(0xFFF5B45A),
    warnBg: Color(0xFF3A2E1A),
  );

  static const light = AppColors(
    surface2: Color(0xFFE9ECEF),
    muted: Color(0xFF59616B),
    line: Color(0xFFC9CFD6),
    accentSoft: Color(0xFFDDF3EA),
    accentText: Color(0xFF0A5E40),
    cardFace: Color(0xFFFFFFFF),
    warn: Color(0xFF8A5300),
    warnBg: Color(0xFFFCEFD9),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      surface2: l(surface2, other.surface2),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      accentSoft: l(accentSoft, other.accentSoft),
      accentText: l(accentText, other.accentText),
      cardFace: l(cardFace, other.cardFace),
      warn: l(warn, other.warn),
      warnBg: l(warnBg, other.warnBg),
    );
  }
}

/// Цвета мастей (четырёхцветная колода).
class SuitColors {
  static const spade = Color(0xFF1A1A1A);
  static const heart = Color(0xFFC9252D);
  static const diamond = Color(0xFF1F63D6);
  static const club = Color(0xFF177A36);
}

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final bg = dark ? const Color(0xFF111315) : const Color(0xFFF4F5F7);
  final surface = dark ? const Color(0xFF1B1E22) : const Color(0xFFFFFFFF);
  final text = dark ? const Color(0xFFECEEF0) : const Color(0xFF14171A);
  final accent = dark ? const Color(0xFF3DDC97) : const Color(0xFF0E7F57);
  final onAccent = dark ? const Color(0xFF0B2A1C) : const Color(0xFFFFFFFF);
  final ext = dark ? AppColors.dark : AppColors.light;

  // Шкала: 13 подписи, 15 текст, 20 заголовки, 28 эквити, 32 главный результат.
  final textTheme = TextTheme(
    bodySmall: TextStyle(fontSize: 13, color: ext.muted),
    bodyMedium: TextStyle(fontSize: 15, color: text),
    bodyLarge: TextStyle(fontSize: 15, color: text),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    headlineSmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: text,
    ),
    headlineMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: accent,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: 'GolosText',
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: b)
        .copyWith(
          primary: accent,
          onPrimary: onAccent,
          surface: surface,
          onSurface: text,
        ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontFamily: 'GolosText'),
    ),
    drawerTheme: DrawerThemeData(backgroundColor: surface),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    extensions: [ext],
  );
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
