import 'dart:math' as math;

/// A collection of built-in functions that can be used in expressions.
///
/// This provides commonly needed mathematical and utility functions that
/// can be added to the evaluation context.
///
/// Example:
/// ```dart
/// var evaluator = const ExpressionEvaluator();
/// var expr = Expression.parse('sqrt(16) + abs(-5)');
/// var result = evaluator.eval(expr, BuiltInFunctions.mathFunctions);
/// print(result); // 9.0
/// ```
class BuiltInFunctions {
  /// Mathematical functions from dart:math
  static final Map<String, dynamic> mathFunctions = {
    // Trigonometric
    'sin': math.sin,
    'cos': math.cos,
    'tan': math.tan,
    'asin': math.asin,
    'acos': math.acos,
    'atan': math.atan,
    'atan2': math.atan2,

    // Hyperbolic
    'sinh': _sinh,
    'cosh': _cosh,
    'tanh': _tanh,

    // Power and roots
    'sqrt': math.sqrt,
    'pow': math.pow,
    'exp': math.exp,
    'log': math.log,

    // Rounding
    'ceil': (num n) => n.ceil(),
    'floor': (num n) => n.floor(),
    'round': (num n) => n.round(),
    'truncate': (num n) => n.truncate(),

    // Absolute value and sign
    'abs': (num n) => n.abs(),
    'sign': (num n) => n.sign,

    // Min/Max
    'min': math.min,
    'max': math.max,

    // Constants
    'pi': math.pi,
    'e': math.e,
  };

  /// String manipulation functions
  static final Map<String, dynamic> stringFunctions = {
    'toLowerCase': (String s) => s.toLowerCase(),
    'toUpperCase': (String s) => s.toUpperCase(),
    'trim': (String s) => s.trim(),
    'substring': (String s, int start, [int? end]) => s.substring(start, end),
    'length': (String s) => s.length,
    'contains': (String s, String other) => s.contains(other),
    'startsWith': (String s, String prefix) => s.startsWith(prefix),
    'endsWith': (String s, String suffix) => s.endsWith(suffix),
    'replace': (String s, String from, String to) => s.replaceAll(from, to),
    'split': (String s, String delimiter) => s.split(delimiter),
    'join': (List<String> parts, String separator) => parts.join(separator),
  };

  /// List/Array functions
  static final Map<String, dynamic> listFunctions = {
    'length': (List l) => l.length,
    'isEmpty': (List l) => l.isEmpty,
    'isNotEmpty': (List l) => l.isNotEmpty,
    'first': (List l) => l.first,
    'last': (List l) => l.last,
    'contains': (List l, dynamic item) => l.contains(item),
    'indexOf': (List l, dynamic item) => l.indexOf(item),
    'reverse': (List l) => l.reversed.toList(),
    'sort': (List l) => (l..sort()).toList(),
    'sum': (List<num> l) => l.reduce((a, b) => a + b),
    'average': (List<num> l) => l.reduce((a, b) => a + b) / l.length,
  };

  /// Type checking functions
  static final Map<String, dynamic> typeCheckFunctions = {
    'isNull': (dynamic v) => v == null,
    'isNotNull': (dynamic v) => v != null,
    'isString': (dynamic v) => v is String,
    'isNumber': (dynamic v) => v is num,
    'isBool': (dynamic v) => v is bool,
    'isList': (dynamic v) => v is List,
    'isMap': (dynamic v) => v is Map,
  };

  /// All built-in functions combined
  static Map<String, dynamic> get all => {
        ...mathFunctions,
        ...stringFunctions,
        ...listFunctions,
        ...typeCheckFunctions,
      };

  /// Creates a context map with only safe, commonly used functions
  static Map<String, dynamic> get safe => {
        ...mathFunctions,
        // Safe string operations
        'toLowerCase': (String s) => s.toLowerCase(),
        'toUpperCase': (String s) => s.toUpperCase(),
        'trim': (String s) => s.trim(),
        'length': (dynamic v) => v is String ? v.length : (v as List).length,
        // Safe type checks
        'isNull': (dynamic v) => v == null,
        'isNotNull': (dynamic v) => v != null,
      };

  // Helper functions for hyperbolic trig
  static double _sinh(num x) {
    final ex = math.exp(x.toDouble());
    final enx = math.exp(-x.toDouble());
    return (ex - enx) / 2;
  }

  static double _cosh(num x) {
    final ex = math.exp(x.toDouble());
    final enx = math.exp(-x.toDouble());
    return (ex + enx) / 2;
  }

  static double _tanh(num x) => _sinh(x) / _cosh(x);
}
