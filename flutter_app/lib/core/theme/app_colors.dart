import 'package:flutter/material.dart';

/// App color palette — exact hex values from design spec.
/// Use these constants everywhere; never hardcode hex values in UI files.
abstract final class AppColors {
  static bool isLightMode = false;

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static Color get background     => isLightMode ? const Color(0xFFF8FAFC) : const Color(0xFF050B18);
  static Color get card           => isLightMode ? const Color(0xFFFFFFFF) : const Color(0xFF101827);
  static Color get cardElevated   => isLightMode ? const Color(0xFFF1F5F9) : const Color(0xFF152035);

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primaryPurple  = Color(0xFF7C3AED);
  static const Color secondaryPurple= Color(0xFF8B5CF6);
  static const Color purpleGlow     = Color(0x337C3AED);

  // ── Text ──────────────────────────────────────────────────────────────────
  static Color get textWhite      => isLightMode ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  static Color get textGray       => isLightMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color get textDimmed     => isLightMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color successGreen   = Color(0xFF22C55E);
  static const Color alertRed       = Color(0xFFEF4444);

  // ── Domain Accent ─────────────────────────────────────────────────────────
  static const Color medicalBlue    = Color(0xFF2563EB);
  static const Color legalGold      = Color(0xFFD4A017);
  static const Color agriGreen      = Color(0xFF16A34A);
  static const Color safetyOrange   = Color(0xFFEA580C);
  static const Color eduCyan        = Color(0xFF0891B2);

  // ── Structure ─────────────────────────────────────────────────────────────
  static Color get border         => isLightMode ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
  static Color get divider        => isLightMode ? const Color(0xFFCBD5E1) : const Color(0xFF0F1929);
  static Color get inputFill      => isLightMode ? const Color(0xFFF8FAFC) : const Color(0xFF0D1526);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, secondaryPurple],
  );

  static final LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [const Color(0xFF0A0F1E), background],
  );

  static const LinearGradient medicalGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), medicalBlue],
  );

  static const LinearGradient legalGradient = LinearGradient(
    colors: [Color(0xFFB45309), legalGold],
  );

  static const LinearGradient agriGradient = LinearGradient(
    colors: [Color(0xFF15803D), agriGreen],
  );

  static const LinearGradient safetyGradient = LinearGradient(
    colors: [Color(0xFFC2410C), safetyOrange],
  );

  static const LinearGradient eduGradient = LinearGradient(
    colors: [Color(0xFF0369A1), eduCyan],
  );
}
