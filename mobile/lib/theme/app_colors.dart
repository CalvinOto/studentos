import 'package:flutter/material.dart';

/// Fixed dark navy used for solid buttons/cards that should stay dark
/// regardless of light/dark mode (matches the web version's "STRONG" token).
const Color strongInk = Color(0xFF22303F);

class AppColors extends ThemeExtension<AppColors> {
  final Color ink;
  final Color inkSoft;
  final Color paper;
  final Color paperRaised;
  final Color line;
  final Color lineSoft;
  final Color backdrop;

  const AppColors({
    required this.ink,
    required this.inkSoft,
    required this.paper,
    required this.paperRaised,
    required this.line,
    required this.lineSoft,
    required this.backdrop,
  });

  @override
  AppColors copyWith({
    Color? ink,
    Color? inkSoft,
    Color? paper,
    Color? paperRaised,
    Color? line,
    Color? lineSoft,
    Color? backdrop,
  }) {
    return AppColors(
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      paper: paper ?? this.paper,
      paperRaised: paperRaised ?? this.paperRaised,
      line: line ?? this.line,
      lineSoft: lineSoft ?? this.lineSoft,
      backdrop: backdrop ?? this.backdrop,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      ink: Color.lerp(ink, other.ink, t) ?? ink,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t) ?? inkSoft,
      paper: Color.lerp(paper, other.paper, t) ?? paper,
      paperRaised: Color.lerp(paperRaised, other.paperRaised, t) ?? paperRaised,
      line: Color.lerp(line, other.line, t) ?? line,
      lineSoft: Color.lerp(lineSoft, other.lineSoft, t) ?? lineSoft,
      backdrop: Color.lerp(backdrop, other.backdrop, t) ?? backdrop,
    );
  }

  static const light = AppColors(
    ink: Color(0xFF22303F),
    inkSoft: Color(0xFF5B5A52),
    paper: Color(0xFFF3EFE4),
    paperRaised: Color(0xFFFBF9F3),
    line: Color(0xFFCFC9BA),
    lineSoft: Color(0xFFE3DECF),
    backdrop: Color(0xFFE7E3D8),
  );

  static const dark = AppColors(
    ink: Color(0xFFF2EFE6),
    inkSoft: Color(0xFFA9A79C),
    paper: Color(0xFF1B1F22),
    paperRaised: Color(0xFF242A2E),
    line: Color(0xFF3A3F42),
    lineSoft: Color(0xFF2A2F32),
    backdrop: Color(0xFF15181A),
  );
}

const Color teal = Color(0xFF1F6F5C);
const Color tealDeep = Color(0xFF154D40);
const Color tealTint = Color(0xFFDEEBE6);
const Color amber = Color(0xFFD98E2B);
const Color amberDeep = Color(0xFF8C5C13);
const Color amberTint = Color(0xFFF7E7CC);
const Color coral = Color(0xFFC1503A);
const Color coralDeep = Color(0xFF83321F);
const Color coralTint = Color(0xFFF3DCD5);

Color swatchSolid(String name) {
  switch (name) {
    case 'teal':
      return teal;
    case 'amber':
      return amber;
    case 'coral':
      return coral;
    default:
      return strongInk;
  }
}

Color swatchTint(String name) {
  switch (name) {
    case 'teal':
      return tealTint;
    case 'amber':
      return amberTint;
    case 'coral':
      return coralTint;
    default:
      return const Color(0xFFE4E2DC);
  }
}

Color swatchDeep(String name) {
  switch (name) {
    case 'teal':
      return tealDeep;
    case 'amber':
      return amberDeep;
    case 'coral':
      return coralDeep;
    default:
      return const Color(0xFF0F1620);
  }
}
