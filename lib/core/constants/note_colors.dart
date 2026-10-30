import 'package:flutter/material.dart';

class NoteColorPalette {
  final int index;
  final String nameEn;
  final String nameAr;
  final Color stripeColor;
  final Color bodyColor;
  final Color headerColor;
  final Color textColor;

  const NoteColorPalette({
    required this.index,
    required this.nameEn,
    required this.nameAr,
    required this.stripeColor,
    required this.bodyColor,
    required this.headerColor,
    required this.textColor,
  });

  /// Generates a complete NoteColorPalette from any arbitrary Color and paper tint ratio (0.45..0.95)
  factory NoteColorPalette.fromCustomColor(
    Color baseColor, {
    double paperWhiteRatio = 0.84,
    String? customLabel,
    int index = 999,
  }) {
    final r = baseColor.red;
    final g = baseColor.green;
    final b = baseColor.blue;
    final bodyR = (r * (1 - paperWhiteRatio) + 255 * paperWhiteRatio).round().clamp(0, 255);
    final bodyG = (g * (1 - paperWhiteRatio) + 255 * paperWhiteRatio).round().clamp(0, 255);
    final bodyB = (b * (1 - paperWhiteRatio) + 255 * paperWhiteRatio).round().clamp(0, 255);

    final hdrR = (r * 0.86).round().clamp(0, 255);
    final hdrG = (g * 0.86).round().clamp(0, 255);
    final hdrB = (b * 0.86).round().clamp(0, 255);

    final hexStr = '#${baseColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    return NoteColorPalette(
      index: index,
      nameEn: customLabel ?? hexStr,
      nameAr: customLabel ?? hexStr,
      stripeColor: baseColor,
      bodyColor: Color.fromARGB(255, bodyR, bodyG, bodyB),
      headerColor: Color.fromARGB(255, hdrR, hdrG, hdrB),
      textColor: const Color(0xFF1E293B),
    );
  }
}

class NoteColors {
  static const List<NoteColorPalette> defaultPalettes = [
    NoteColorPalette(
      index: 0,
      nameEn: 'Red',
      nameAr: 'أحمر',
      stripeColor: Color(0xFFE53935),
      bodyColor: Color(0xFFFFEBEE),
      headerColor: Color(0xFFD32F2F),
      textColor: Color(0xFF3E2723),
    ),
    NoteColorPalette(
      index: 1,
      nameEn: 'Orange',
      nameAr: 'برتقالي',
      stripeColor: Color(0xFFFB8C00),
      bodyColor: Color(0xFFFFF3E0),
      headerColor: Color(0xFFF57C00),
      textColor: Color(0xFF3E2723),
    ),
    NoteColorPalette(
      index: 2,
      nameEn: 'Yellow',
      nameAr: 'أصفر',
      stripeColor: Color(0xFFFDD835),
      bodyColor: Color(0xFFFFFDE7),
      headerColor: Color(0xFFFBC02D),
      textColor: Color(0xFF212121),
    ),
    NoteColorPalette(
      index: 3,
      nameEn: 'Green',
      nameAr: 'أخضر',
      stripeColor: Color(0xFF43A047),
      bodyColor: Color(0xFFE8F5E9),
      headerColor: Color(0xFF388E3C),
      textColor: Color(0xFF1B5E20),
    ),
    NoteColorPalette(
      index: 4,
      nameEn: 'Blue',
      nameAr: 'أزرق',
      stripeColor: Color(0xFF1E88E5),
      bodyColor: Color(0xFFE3F2FD),
      headerColor: Color(0xFF1976D2),
      textColor: Color(0xFF0D47A1),
    ),
    NoteColorPalette(
      index: 5,
      nameEn: 'Purple',
      nameAr: 'بنفسجي',
      stripeColor: Color(0xFF8E24AA),
      bodyColor: Color(0xFFF3E5F5),
      headerColor: Color(0xFF7B1FA2),
      textColor: Color(0xFF4A148C),
    ),
    NoteColorPalette(
      index: 6,
      nameEn: 'Black',
      nameAr: 'أسود',
      stripeColor: Color(0xFF263238),
      bodyColor: Color(0xFFCFD8DC),
      headerColor: Color(0xFF37474F),
      textColor: Color(0xFF212121),
    ),
    NoteColorPalette(
      index: 7,
      nameEn: 'Grey',
      nameAr: 'رمادي',
      stripeColor: Color(0xFF757575),
      bodyColor: Color(0xFFF5F5F5),
      headerColor: Color(0xFF616161),
      textColor: Color(0xFF212121),
    ),
    NoteColorPalette(
      index: 8,
      nameEn: 'White',
      nameAr: 'أبيض',
      stripeColor: Color(0xFFBDBDBD),
      bodyColor: Color(0xFFFFFFFF),
      headerColor: Color(0xFF757575),
      textColor: Color(0xFF212121),
    ),
  ];

  static NoteColorPalette byIndex(int index, [List<NoteColorPalette> custom = const []]) {
    final all = [...defaultPalettes, ...custom];
    for (final p in all) {
      if (p.index == index) return p;
    }
    return defaultPalettes[2];
  }
}
