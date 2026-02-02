library core;

// Sketch Design System exports
export 'sketch_design_tokens.dart';
export 'sketch_color_palettes.dart';

// Exceptions
export 'src/exceptions/auth_exception.dart';
export 'src/exceptions/network_exception.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
