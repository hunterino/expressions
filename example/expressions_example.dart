import 'package:expressions/expressions.dart';
import 'dart:math';
import 'dart:async';

void main() async {
  example1BasicEvaluation();
  example2MemberAccess();
  example3AsyncEvaluation();
  await example4AsyncStream();
}

/// Example 1: Basic expression evaluation
void example1BasicEvaluation() {
  print('=== Example 1: Basic Evaluation ===');

  // Parse expression
  var expression = Expression.parse('cos(x)*cos(x)+sin(x)*sin(x)==1');

  // Create context with variables and functions
  var context = {'x': pi / 5, 'cos': cos, 'sin': sin};

  // Evaluate expression
  const evaluator = ExpressionEvaluator();
  var result = evaluator.eval(expression, context);

  print('cos²(x) + sin²(x) == 1: $result'); // true
  print('');
}

/// Example 2: Member access using MemberAccessor
void example2MemberAccess() {
  print('=== Example 2: Member Access ===');

  // Parse expression
  var expression = Expression.parse("'Hello ' + person.name");

  // Create evaluator with member accessors
  final evaluator = ExpressionEvaluator(memberAccessors: [
    MemberAccessor<Person>({
      'name': (p) => p.name,
      'age': (p) => p.age,
      'email': (p) => p.email,
    }),
  ]);

  // Create context
  var context = {'person': Person('Jane', 25, 'jane@example.com')};

  // Evaluate
  var result = evaluator.eval(expression, context);
  print('Result: $result'); // Hello Jane

  // Access other members
  var ageExpr = Expression.parse('person.age >= 18');
  var isAdult = evaluator.eval(ageExpr, context);
  print('Is adult: $isAdult'); // true
  print('');
}

/// Example 3: Async evaluation with Futures
void example3AsyncEvaluation() {
  print('=== Example 3: Async with Futures ===');

  const evaluator = AsyncExpressionEvaluator();
  var expression = Expression.parse('x + y');

  var result = evaluator.eval(expression, {
    'x': Future.value(10),
    'y': Future.value(20),
  });

  result.listen((value) => print('10 + 20 = $value')); // 30
  print('');
}

/// Example 4: Reactive evaluation with Streams
Future<void> example4AsyncStream() async {
  print('=== Example 4: Reactive Streams ===');

  const evaluator = AsyncExpressionEvaluator();
  var expression = Expression.parse('temperature > threshold');

  var temperatureController = StreamController<double>();
  var thresholdController = StreamController<double>();

  var alarm = evaluator.eval(expression, {
    'temperature': temperatureController.stream,
    'threshold': thresholdController.stream,
  });

  alarm.listen((isAlarm) {
    print('Alarm: ${isAlarm ? "🔥 HIGH TEMPERATURE!" : "✓ Normal"}');
  });

  // Simulate temperature readings
  thresholdController.add(30.0);
  await Future.delayed(Duration(milliseconds: 100));

  temperatureController.add(25.0); // Normal
  await Future.delayed(Duration(milliseconds: 100));

  temperatureController.add(35.0); // High!
  await Future.delayed(Duration(milliseconds: 100));

  temperatureController.add(28.0); // Normal again
  await Future.delayed(Duration(milliseconds: 100));

  await temperatureController.close();
  await thresholdController.close();
  print('');
}

/// Example Person class
class Person {
  final String name;
  final int age;
  final String email;

  Person(this.name, this.age, this.email);
}
