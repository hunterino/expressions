import 'package:quiver/core.dart';
import 'parser.dart';
import 'package:petitparser/petitparser.dart';

/// Represents an identifier in an expression.
///
/// Identifiers are used for variable names and property names. They cannot
/// be reserved keywords like 'null', 'true', 'false', or 'this'.
class Identifier {
  /// The name of this identifier.
  final String name;

  /// Creates an identifier with the given [name].
  ///
  /// Throws an assertion error if the name is a reserved keyword.
  Identifier(this.name) {
    assert(name != 'null');
    assert(name != 'false');
    assert(name != 'true');
    assert(name != 'this');
  }

  @override
  String toString() => name;
}

/// Base class for all expression types.
///
/// An expression represents a parsed syntax tree that can be evaluated
/// against a context map to produce a value.
///
/// Use [Expression.parse] to create an expression from a string, or
/// [Expression.tryParse] for a non-throwing version.
///
/// Example:
/// ```dart
/// var expr = Expression.parse('x + y * 2');
/// var evaluator = const ExpressionEvaluator();
/// var result = evaluator.eval(expr, {'x': 10, 'y': 5});
/// print(result); // 20
/// ```
abstract class Expression {
  /// Returns a string representation suitable for use in a larger expression.
  ///
  /// This may include parentheses for compound expressions to maintain
  /// correct precedence when embedded in other expressions.
  String toTokenString();

  static final ExpressionParser _parser = ExpressionParser();

  /// Parses an expression string and returns the parsed [Expression],
  /// or null if parsing fails.
  ///
  /// Unlike [parse], this method does not throw on invalid input.
  ///
  /// Example:
  /// ```dart
  /// var expr = Expression.tryParse('x + y');
  /// if (expr != null) {
  ///   // use expression
  /// }
  /// ```
  static Expression? tryParse(String formattedString) {
    final result = _parser.expression.trim().end().parse(formattedString);
    return result is Success ? result.value : null;
  }

  /// Parses an expression string and returns the parsed [Expression].
  ///
  /// Throws a [ParserException] if the string cannot be parsed.
  ///
  /// Example:
  /// ```dart
  /// var expr = Expression.parse('x + y * 2');
  /// ```
  static Expression parse(String formattedString) =>
      _parser.expression.trim().end().parse(formattedString).value;
}

/// Base class for simple expressions that don't need parentheses when embedded.
abstract class SimpleExpression implements Expression {
  @override
  String toTokenString() => toString();
}

/// Base class for compound expressions that need parentheses when embedded.
abstract class CompoundExpression implements Expression {
  @override
  String toTokenString() => '($this)';
}

/// A literal value in an expression.
///
/// Literals can be numbers, strings, booleans, null, arrays, or maps.
///
/// Example:
/// ```dart
/// var num = Literal(42);
/// var str = Literal('hello');
/// var arr = Literal([1, 2, 3]);
/// ```
class Literal extends SimpleExpression {
  /// The actual value of this literal.
  final dynamic value;

  /// The raw string representation of this literal.
  final String raw;

  /// Creates a literal with the given [value].
  ///
  /// The optional [raw] parameter provides the string representation.
  /// If not provided, it will be generated automatically with proper escaping.
  Literal(this.value, [String? raw])
      : raw = raw ?? (value is String ? '"${_escapeString(value)}"' : '$value');

  static String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t')
        .replaceAll('\b', '\\b')
        .replaceAll('\f', '\\f');
  }

  @override
  String toString() => raw;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is Literal && other.value == value;
}

/// A variable reference in an expression.
///
/// Example: `x`, `myVariable`
class Variable extends SimpleExpression {
  /// The identifier for this variable.
  final Identifier identifier;

  /// Creates a variable with the given [identifier].
  Variable(this.identifier);

  @override
  String toString() => '$identifier';
}

/// The `this` keyword expression.
class ThisExpression extends SimpleExpression {}

/// A member access expression.
///
/// Example: `object.property`, `person.name`
class MemberExpression extends SimpleExpression {
  /// The object being accessed.
  final Expression object;

  /// The property being accessed.
  final Identifier property;

  /// Creates a member expression accessing [property] on [object].
  MemberExpression(this.object, this.property);

  @override
  String toString() => '${object.toTokenString()}.$property';
}

/// An index access expression.
///
/// Example: `array[0]`, `map['key']`
class IndexExpression extends SimpleExpression {
  /// The object being indexed.
  final Expression object;

  /// The index expression.
  final Expression index;

  /// Creates an index expression accessing [index] on [object].
  IndexExpression(this.object, this.index);

  @override
  String toString() => '${object.toTokenString()}[$index]';
}

/// A function call expression.
///
/// Example: `foo()`, `Math.sqrt(16)`, `sum(1, 2, 3)`
class CallExpression extends SimpleExpression {
  /// The function being called.
  final Expression callee;

  /// The arguments to the function.
  final List<Expression> arguments;

  /// Creates a call expression calling [callee] with [arguments].
  CallExpression(this.callee, this.arguments);

  @override
  String toString() => '${callee.toTokenString()}(${arguments.join(', ')})';
}

/// A unary operation expression.
///
/// Example: `-x`, `!flag`, `~bits`
class UnaryExpression extends SimpleExpression {
  /// The operator: '-', '+', '!', or '~'.
  final String operator;

  /// The operand.
  final Expression argument;

  /// Whether this is a prefix operator (true) or postfix (false).
  final bool prefix;

  /// Creates a unary expression with the given [operator] and [argument].
  UnaryExpression(this.operator, this.argument, {this.prefix = true});

  @override
  String toString() => '$operator$argument';
}

/// A binary operation expression.
///
/// Binary expressions support arithmetic (+, -, *, /, %), comparison
/// (==, !=, <, >, <=, >=), logical (&&, ||), and bitwise (&, |, ^) operators.
///
/// Example: `x + y`, `a * b + c`, `x == y`
class BinaryExpression extends CompoundExpression {
  /// The operator string.
  final String operator;

  /// The left operand.
  final Expression left;

  /// The right operand.
  final Expression right;

  /// Creates a binary expression with [operator], [left], and [right].
  BinaryExpression(this.operator, this.left, this.right);

  /// Returns the precedence value for the given [operator].
  static int precedenceForOperator(String operator) =>
      ExpressionParser.binaryOperations[operator]!;

  /// The precedence of this binary expression's operator.
  int get precedence => precedenceForOperator(operator);

  @override
  String toString() {
    var l = (left is BinaryExpression &&
            (left as BinaryExpression).precedence < precedence)
        ? '($left)'
        : '$left';
    var r = (right is BinaryExpression &&
            (right as BinaryExpression).precedence < precedence)
        ? '($right)'
        : '$right';
    return '$l$operator$r';
  }

  @override
  int get hashCode => hash3(left, operator, right);

  @override
  bool operator ==(Object other) =>
      other is BinaryExpression &&
      other.left == left &&
      other.operator == operator &&
      other.right == right;
}

/// A ternary conditional expression.
///
/// Example: `x > 0 ? 'positive' : 'negative'`
class ConditionalExpression extends CompoundExpression {
  /// The test condition.
  final Expression test;

  /// The expression evaluated if test is true.
  final Expression consequent;

  /// The expression evaluated if test is false.
  final Expression alternate;

  /// Creates a conditional expression.
  ConditionalExpression(this.test, this.consequent, this.alternate);

  @override
  String toString() => '$test ? $consequent : $alternate';
}
