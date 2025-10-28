import 'dart:async';

import 'package:expressions/expressions.dart';
import 'package:rxdart/rxdart.dart';

/// Converts a value to a Stream.
Stream _asStream(dynamic v) => v is Stream
    ? v
    : v is Future
        ? Stream.fromFuture(v)
        : Stream.value(v);

/// Wraps a value in a Literal expression.
Literal _asLiteral(dynamic v) {
  if (v is Map) {
    return Literal(v.map((k, v) => MapEntry(_asLiteral(k), _asLiteral(v))));
  }
  if (v is List) {
    return Literal(v.map((v) => _asLiteral(v)).toList());
  }
  return Literal(v);
}

/// An asynchronous expression evaluator that works with Streams and Futures.
///
/// This evaluator extends [ExpressionEvaluator] to handle reactive data sources.
/// When variables in the context are Streams or Futures, the evaluator will
/// automatically combine them and emit results as values change.
///
/// The evaluation result is always a [Stream] that emits values as the
/// source streams emit new values.
///
/// Example:
/// ```dart
/// var evaluator = const AsyncExpressionEvaluator();
/// var expr = Expression.parse('x + y');
///
/// var xController = StreamController<int>();
/// var yController = StreamController<int>();
///
/// var result = evaluator.eval(expr, {
///   'x': xController.stream,
///   'y': yController.stream,
/// });
///
/// result.listen(print);
///
/// xController.add(10); // No output yet, waiting for y
/// yController.add(5);  // Outputs: 15
/// xController.add(20); // Outputs: 25
/// ```
class AsyncExpressionEvaluator extends ExpressionEvaluator {
  final ExpressionEvaluator baseEvaluator = const ExpressionEvaluator();

  /// Creates an async expression evaluator with optional [memberAccessors].
  const AsyncExpressionEvaluator({super.memberAccessors = const []});

  @override
  Stream eval(Expression expression, Map<String, dynamic> context) {
    return _asStream(super.eval(expression, context));
  }

  @override
  Stream evalBinaryExpression(
      BinaryExpression expression, Map<String, dynamic> context) {
    var left = eval(expression.left, context);
    var right = eval(expression.right, context);

    return CombineLatestStream.combine2(left, right, (a, b) {
      return baseEvaluator.evalBinaryExpression(
          BinaryExpression(expression.operator, _asLiteral(a), _asLiteral(b)),
          context);
    });
  }

  @override
  Stream evalUnaryExpression(
      UnaryExpression expression, Map<String, dynamic> context) {
    var argument = eval(expression.argument, context);

    return argument.map((v) {
      return baseEvaluator.evalUnaryExpression(
          UnaryExpression(expression.operator, _asLiteral(v),
              prefix: expression.prefix),
          context);
    });
  }

  @override
  dynamic evalCallExpression(
      CallExpression expression, Map<String, dynamic> context) {
    var callee = eval(expression.callee, context);
    var arguments = expression.arguments.map((e) => eval(e, context)).toList();
    return CombineLatestStream([callee, ...arguments], (l) {
      return baseEvaluator.evalCallExpression(
          CallExpression(
              _asLiteral(l.first), [for (var v in l.skip(1)) _asLiteral(v)]),
          context);
    }).switchMap((v) => _asStream(v));
  }

  @override
  Stream evalConditionalExpression(
      ConditionalExpression expression, Map<String, dynamic> context) {
    var test = eval(expression.test, context);
    var cons = eval(expression.consequent, context);
    var alt = eval(expression.alternate, context);

    return CombineLatestStream.combine3(test, cons, alt, (test, cons, alt) {
      return baseEvaluator.evalConditionalExpression(
          ConditionalExpression(
              _asLiteral(test), _asLiteral(cons), _asLiteral(alt)),
          context);
    });
  }

  @override
  Stream evalIndexExpression(
      IndexExpression expression, Map<String, dynamic> context) {
    var obj = eval(expression.object, context);
    var index = eval(expression.index, context);
    return CombineLatestStream.combine2(obj, index, (obj, index) {
      return baseEvaluator.evalIndexExpression(
          IndexExpression(_asLiteral(obj), _asLiteral(index)), context);
    });
  }

  @override
  Stream evalLiteral(Literal literal, Map<String, dynamic> context) {
    return Stream.value(literal.value);
  }

  @override
  Stream evalThis(ThisExpression expression, Map<String, dynamic> context) {
    return _asStream(baseEvaluator.evalThis(expression, context));
  }

  @override
  Stream evalVariable(Variable variable, Map<String, dynamic> context) {
    return _asStream(baseEvaluator.evalVariable(variable, context));
  }

  @override
  Stream evalMemberExpression(
      MemberExpression expression, Map<String, dynamic> context) {
    var v = eval(expression.object, context);

    return v.switchMap((v) {
      return _asStream(getMember(v, expression.property.name));
    });
  }
}
