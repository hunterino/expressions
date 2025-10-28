// Benchmarks for the expressions library
// Run with: dart benchmark/expression_benchmark.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:expressions/expressions.dart';

void main() async {
  print('=== Expression Library Benchmarks ===\n');

  await runParsingBenchmarks();
  await runEvaluationBenchmarks();
  await runAsyncBenchmarks();
  await runComplexExpressionBenchmarks();

  print('\n=== Benchmarks Complete ===');
}

Future<void> runParsingBenchmarks() async {
  print('## Parsing Benchmarks');

  await benchmark('Parse simple expression', () {
    Expression.parse('x + y');
  }, iterations: 10000);

  await benchmark('Parse complex arithmetic', () {
    Expression.parse('a * b + c / d - e % f');
  }, iterations: 10000);

  await benchmark('Parse nested expression', () {
    Expression.parse('(a + b) * (c - d) / ((e + f) * g)');
  }, iterations: 10000);

  await benchmark('Parse with function calls', () {
    Expression.parse('sqrt(x * x + y * y)');
  }, iterations: 10000);

  await benchmark('Parse with member access', () {
    Expression.parse('person.address.city');
  }, iterations: 10000);

  await benchmark('Parse conditional', () {
    Expression.parse('x > 0 ? "positive" : "negative"');
  }, iterations: 10000);

  print('');
}

Future<void> runEvaluationBenchmarks() async {
  print('## Evaluation Benchmarks');

  const evaluator = ExpressionEvaluator();

  var simpleExpr = Expression.parse('x + y');
  await benchmark('Eval simple arithmetic', () {
    evaluator.eval(simpleExpr, {'x': 5, 'y': 3});
  }, iterations: 100000);

  var complexExpr = Expression.parse('a * b + c / d - e % f');
  await benchmark('Eval complex arithmetic', () {
    evaluator.eval(complexExpr, {
      'a': 5,
      'b': 3,
      'c': 10,
      'd': 2,
      'e': 7,
      'f': 3,
    });
  }, iterations: 100000);

  var nestedExpr = Expression.parse('(a + b) * (c - d) / ((e + f) * g)');
  await benchmark('Eval nested expression', () {
    evaluator.eval(nestedExpr, {
      'a': 5,
      'b': 3,
      'c': 10,
      'd': 2,
      'e': 7,
      'f': 3,
      'g': 2,
    });
  }, iterations: 100000);

  var funcExpr = Expression.parse('sqrt(x * x + y * y)');
  await benchmark('Eval with function', () {
    evaluator.eval(funcExpr, {
      'x': 3,
      'y': 4,
      'sqrt': math.sqrt,
    });
  }, iterations: 100000);

  var conditionalExpr = Expression.parse('x > 0 ? 1 : -1');
  await benchmark('Eval conditional', () {
    evaluator.eval(conditionalExpr, {'x': 5});
  }, iterations: 100000);

  var logicalExpr = Expression.parse('a && b || c');
  await benchmark('Eval logical operators', () {
    evaluator.eval(logicalExpr, {'a': true, 'b': false, 'c': true});
  }, iterations: 100000);

  print('');
}

Future<void> runAsyncBenchmarks() async {
  print('## Async Benchmarks');

  const evaluator = AsyncExpressionEvaluator();

  var expr = Expression.parse('x + y');

  await benchmark('Async eval with values', () async {
    var result = evaluator.eval(expr, {'x': 5, 'y': 3});
    await result.first;
  }, iterations: 1000);

  await benchmark('Async eval with futures', () async {
    var result = evaluator.eval(expr, {
      'x': Future.value(5),
      'y': Future.value(3),
    });
    await result.first;
  }, iterations: 1000);

  print('');
}

Future<void> runComplexExpressionBenchmarks() async {
  print('## Complex Expression Benchmarks');

  const evaluator = ExpressionEvaluator();

  // Physics formula: kinetic energy = 0.5 * m * v^2
  var kineticEnergy = Expression.parse('0.5 * mass * velocity * velocity');
  await benchmark('Physics formula (kinetic energy)', () {
    evaluator.eval(kineticEnergy, {'mass': 10, 'velocity': 5});
  }, iterations: 50000);

  // Pythagorean theorem with function
  var pythagorean = Expression.parse('sqrt(a*a + b*b)');
  await benchmark('Pythagorean theorem', () {
    evaluator.eval(pythagorean, {'a': 3, 'b': 4, 'sqrt': math.sqrt});
  }, iterations: 50000);

  // Quadratic formula discriminant: b^2 - 4*a*c
  var discriminant = Expression.parse('b*b - 4*a*c');
  await benchmark('Quadratic discriminant', () {
    evaluator.eval(discriminant, {'a': 1, 'b': 5, 'c': 6});
  }, iterations: 50000);

  // Compound interest: P * (1 + r)^n (without exponentiation)
  var compoundPart = Expression.parse('principal * (1 + rate)');
  await benchmark('Compound interest (partial)', () {
    evaluator.eval(compoundPart, {'principal': 1000, 'rate': 0.05});
  }, iterations: 50000);

  // Array access
  var arrayAccess = Expression.parse('arr[index]');
  await benchmark('Array index access', () {
    evaluator.eval(arrayAccess, {
      'arr': [1, 2, 3, 4, 5],
      'index': 2,
    });
  }, iterations: 50000);

  print('');
}

/// Runs a benchmark and prints the results
Future<void> benchmark(String name, Function fn,
    {int iterations = 1000, int warmup = 100}) async {
  // Warmup
  for (var i = 0; i < warmup; i++) {
    await fn();
  }

  // Actual benchmark
  var stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    await fn();
  }
  stopwatch.stop();

  var totalMs = stopwatch.elapsedMicroseconds / 1000;
  var avgMicros = stopwatch.elapsedMicroseconds / iterations;
  var opsPerSec = (iterations / (stopwatch.elapsedMilliseconds / 1000)).round();

  print(
      '  $name: ${avgMicros.toStringAsFixed(2)}μs avg, ${opsPerSec.toStringAsFixed(0)} ops/sec ($iterations iterations in ${totalMs.toStringAsFixed(2)}ms)');
}
