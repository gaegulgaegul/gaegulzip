import 'dart:ui';

/// Predefined color palettes for sketch-style design system
///
/// Provides various color schemes that can be used with SketchThemeExtension
/// or individual sketch widgets. Each palette includes primary, secondary,
/// and semantic colors.
///
/// **Usage with SketchThemeExtension:**
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [
///       SketchThemeExtension(
///         borderColor: SketchColorPalettes.pastelPrimary,
///         fillColor: SketchColorPalettes.pastelBackground,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// **Usage with individual widgets:**
/// ```dart
/// SketchButton(
///   text: 'Pastel Button',
///   fillColor: SketchColorPalettes.pastelPrimary,
///   onPressed: () {},
/// )
/// ```
///
/// **Available Palettes:**
/// - Pastel: Soft, muted colors for gentle aesthetics
/// - Vibrant: Bold, saturated colors for energetic designs
/// - Monochrome: Grayscale palette for minimal designs
/// - Earthy: Natural, warm tones
/// - Ocean: Cool blue and teal tones
/// - Sunset: Warm orange and pink tones
class SketchColorPalettes {
  // ============================================================
  // PASTEL PALETTE - Soft, muted colors
  // ============================================================

  /// Pastel primary color (soft pink)
  static const Color pastelPrimary = Color(0xFFFFB3BA);

  /// Pastel secondary color (soft blue)
  static const Color pastelSecondary = Color(0xFFBAE1FF);

  /// Pastel accent color (soft yellow)
  static const Color pastelAccent = Color(0xFFFFDFBA);

  /// Pastel success color (soft green)
  static const Color pastelSuccess = Color(0xFFBAFFC9);

  /// Pastel warning color (soft orange)
  static const Color pastelWarning = Color(0xFFFFCCB3);

  /// Pastel error color (soft red)
  static const Color pastelError = Color(0xFFFFABAB);

  /// Pastel background color (very light cream)
  static const Color pastelBackground = Color(0xFFFFFBF5);

  /// Pastel surface color (light cream)
  static const Color pastelSurface = Color(0xFFFFF5E8);

  // ============================================================
  // VIBRANT PALETTE - Bold, saturated colors
  // ============================================================

  /// Vibrant primary color (bright coral)
  static const Color vibrantPrimary = Color(0xFFFF6B6B);

  /// Vibrant secondary color (bright teal)
  static const Color vibrantSecondary = Color(0xFF4ECDC4);

  /// Vibrant accent color (bright yellow)
  static const Color vibrantAccent = Color(0xFFFFE66D);

  /// Vibrant success color (bright green)
  static const Color vibrantSuccess = Color(0xFF95E1D3);

  /// Vibrant warning color (bright orange)
  static const Color vibrantWarning = Color(0xFFF38181);

  /// Vibrant error color (bright red)
  static const Color vibrantError = Color(0xFFEF476F);

  /// Vibrant background color (white)
  static const Color vibrantBackground = Color(0xFFFFFFFF);

  /// Vibrant surface color (very light gray)
  static const Color vibrantSurface = Color(0xFFF8F9FA);

  // ============================================================
  // MONOCHROME PALETTE - Grayscale only
  // ============================================================

  /// Monochrome primary color (dark gray)
  static const Color monochromePrimary = Color(0xFF2D3436);

  /// Monochrome secondary color (medium gray)
  static const Color monochromeSecondary = Color(0xFF636E72);

  /// Monochrome accent color (light gray)
  static const Color monochromeAccent = Color(0xFFB2BEC3);

  /// Monochrome success color (gray-green)
  static const Color monochromeSuccess = Color(0xFF74B9FF);

  /// Monochrome warning color (gray-yellow)
  static const Color monochromeWarning = Color(0xFFFDCB6E);

  /// Monochrome error color (gray-red)
  static const Color monochromeError = Color(0xFFD63031);

  /// Monochrome background color (very light gray)
  static const Color monochromeBackground = Color(0xFFF5F6FA);

  /// Monochrome surface color (light gray)
  static const Color monochromeSurface = Color(0xFFDFE6E9);

  // ============================================================
  // EARTHY PALETTE - Natural, warm tones
  // ============================================================

  /// Earthy primary color (terracotta)
  static const Color earthyPrimary = Color(0xFFE07A5F);

  /// Earthy secondary color (sage green)
  static const Color earthySecondary = Color(0xFF81B29A);

  /// Earthy accent color (golden)
  static const Color earthyAccent = Color(0xFFF2CC8F);

  /// Earthy success color (moss green)
  static const Color earthySuccess = Color(0xFF6A994E);

  /// Earthy warning color (amber)
  static const Color earthyWarning = Color(0xFFF4A261);

  /// Earthy error color (rust)
  static const Color earthyError = Color(0xFFBC4749);

  /// Earthy background color (cream)
  static const Color earthyBackground = Color(0xFFF4F1DE);

  /// Earthy surface color (light beige)
  static const Color earthySurface = Color(0xFFE8E2D8);

  // ============================================================
  // OCEAN PALETTE - Cool blue and teal tones
  // ============================================================

  /// Ocean primary color (deep blue)
  static const Color oceanPrimary = Color(0xFF0077B6);

  /// Ocean secondary color (turquoise)
  static const Color oceanSecondary = Color(0xFF00B4D8);

  /// Ocean accent color (cyan)
  static const Color oceanAccent = Color(0xFF90E0EF);

  /// Ocean success color (sea green)
  static const Color oceanSuccess = Color(0xFF06A77D);

  /// Ocean warning color (coral)
  static const Color oceanWarning = Color(0xFFFF9F1C);

  /// Ocean error color (salmon)
  static const Color oceanError = Color(0xFFE63946);

  /// Ocean background color (very light blue)
  static const Color oceanBackground = Color(0xFFCAF0F8);

  /// Ocean surface color (light cyan)
  static const Color oceanSurface = Color(0xFFADE8F4);

  // ============================================================
  // SUNSET PALETTE - Warm orange and pink tones
  // ============================================================

  /// Sunset primary color (coral)
  static const Color sunsetPrimary = Color(0xFFFF6B9D);

  /// Sunset secondary color (peach)
  static const Color sunsetSecondary = Color(0xFFFFA384);

  /// Sunset accent color (soft yellow)
  static const Color sunsetAccent = Color(0xFFFFC947);

  /// Sunset success color (mint)
  static const Color sunsetSuccess = Color(0xFF88D498);

  /// Sunset warning color (orange)
  static const Color sunsetWarning = Color(0xFFFFAB73);

  /// Sunset error color (rose)
  static const Color sunsetError = Color(0xFFFF6B9D);

  /// Sunset background color (very light pink)
  static const Color sunsetBackground = Color(0xFFFFF5F7);

  /// Sunset surface color (light peach)
  static const Color sunsetSurface = Color(0xFFFFE5D9);

  // ============================================================
  // PALETTE COLLECTIONS
  // ============================================================

  /// Get all colors from a specific palette
  ///
  /// Returns a map with semantic color names and their values
  static Map<String, Color> getPalette(String paletteName) {
    switch (paletteName.toLowerCase()) {
      case 'pastel':
        return {
          'primary': pastelPrimary,
          'secondary': pastelSecondary,
          'accent': pastelAccent,
          'success': pastelSuccess,
          'warning': pastelWarning,
          'error': pastelError,
          'background': pastelBackground,
          'surface': pastelSurface,
        };
      case 'vibrant':
        return {
          'primary': vibrantPrimary,
          'secondary': vibrantSecondary,
          'accent': vibrantAccent,
          'success': vibrantSuccess,
          'warning': vibrantWarning,
          'error': vibrantError,
          'background': vibrantBackground,
          'surface': vibrantSurface,
        };
      case 'monochrome':
        return {
          'primary': monochromePrimary,
          'secondary': monochromeSecondary,
          'accent': monochromeAccent,
          'success': monochromeSuccess,
          'warning': monochromeWarning,
          'error': monochromeError,
          'background': monochromeBackground,
          'surface': monochromeSurface,
        };
      case 'earthy':
        return {
          'primary': earthyPrimary,
          'secondary': earthySecondary,
          'accent': earthyAccent,
          'success': earthySuccess,
          'warning': earthyWarning,
          'error': earthyError,
          'background': earthyBackground,
          'surface': earthySurface,
        };
      case 'ocean':
        return {
          'primary': oceanPrimary,
          'secondary': oceanSecondary,
          'accent': oceanAccent,
          'success': oceanSuccess,
          'warning': oceanWarning,
          'error': oceanError,
          'background': oceanBackground,
          'surface': oceanSurface,
        };
      case 'sunset':
        return {
          'primary': sunsetPrimary,
          'secondary': sunsetSecondary,
          'accent': sunsetAccent,
          'success': sunsetSuccess,
          'warning': sunsetWarning,
          'error': sunsetError,
          'background': sunsetBackground,
          'surface': sunsetSurface,
        };
      default:
        return {}; // Empty map for unknown palette
    }
  }

  /// Get list of all available palette names
  static List<String> get availablePalettes => [
        'pastel',
        'vibrant',
        'monochrome',
        'earthy',
        'ocean',
        'sunset',
      ];
}
