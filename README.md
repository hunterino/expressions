[![Ceasefire Now](https://badge.techforpalestine.org/default)](https://techforpalestine.org/learn-more)

[:heart: sponsor](https://github.com/sponsors/rbellens)

# expressions

[![Build Status](https://github.com/appsup-dart/expressions/workflows/Dart%20CI/badge.svg)](https://github.com/appsup-dart/expressions/actions)
[![pub package](https://img.shields.io/pub/v/expressions.svg)](https://pub.dev/packages/expressions)
[![Coverage](https://codecov.io/gh/appsup-dart/expressions/branch/master/graph/badge.svg)](https://codecov.io/gh/appsup-dart/expressions)
[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://appsup-dart.github.io/expressions/)

A library to parse and evaluate simple expressions with support for reactive streams.

This library can handle simple expressions, but no operations, blocks of code, control flow statements and so on.
It supports a syntax that is common to most programming languages (so no special things like string interpolation,
cascade notation, named parameters).

It is partly inspired by [jsep](http://jsep.from.so/).

## Features

- 🚀 **Parse and evaluate expressions** - Support for arithmetic, logical, comparison, and bitwise operators
- 🔄 **Reactive evaluation** - Built-in support for Streams and Futures with `AsyncExpressionEvaluator`
- 🎯 **Type-safe member access** - Define custom accessors for object properties
- 📦 **Built-in functions** - Math, string, and list manipulation functions included
- 🎨 **Extensible** - Easy to add custom functions and operators
- 📍 **Source location tracking** - Better error messages with line/column information
- ⚡ **High performance** - Optimized parser and evaluator (see benchmarks)

## Usage

### Basic Evaluation

```dart
import 'package:expressions/expressions.dart';

// Parse and evaluate a simple expression
var expression = Expression.parse('x + y * 2');
const evaluator = ExpressionEvaluator();

var result = evaluator.eval(expression, {'x': 10, 'y': 5});
print(result); // 20
```

### Member Access

```dart
import 'package:expressions/expressions.dart';

class Person {
  final String name;
  final int age;
  Person(this.name, this.age);
}

// Create evaluator with member accessors
final evaluator = ExpressionEvaluator(memberAccessors: [
  MemberAccessor<Person>({
    'name': (p) => p.name,
    'age': (p) => p.age,
  }),
]);

var expr = Expression.parse("'Hello ' + person.name");
var result = evaluator.eval(expr, {
  'person': Person('Jane', 25)
});
print(result); // Hello Jane
```

### Built-in Functions

```dart
import 'package:expressions/expressions.dart';

// Use built-in math functions
var expr = Expression.parse('sqrt(pow(x, 2) + pow(y, 2))');
const evaluator = ExpressionEvaluator();

var result = evaluator.eval(expr, {
  ...BuiltInFunctions.mathFunctions,
  'x': 3,
  'y': 4,
});
print(result); // 5.0
```

### Reactive Evaluation with Streams

```dart
import 'dart:async';
import 'package:expressions/expressions.dart';

const evaluator = AsyncExpressionEvaluator();
var expr = Expression.parse('temperature > threshold');

var tempController = StreamController<double>();
var thresholdController = StreamController<double>();

var alarm = evaluator.eval(expr, {
  'temperature': tempController.stream,
  'threshold': thresholdController.stream,
});

alarm.listen((isAlarm) {
  print(isAlarm ? 'ALARM!' : 'Normal');
});

thresholdController.add(30.0);
tempController.add(25.0); // Normal
tempController.add(35.0); // ALARM!
```



## Supported Operators

### Arithmetic
`+` `-` `*` `/` `%` `~/` (integer division)

### Comparison
`==` `!=` `<` `>` `<=` `>=`

### Logical
`&&` `||` `!`

### Bitwise
`&` `|` `^` `~` `<<` `>>`

### Other
`??` (null-coalescing), `? :` (ternary conditional)

## Performance

Run benchmarks with:
```bash
dart benchmark/expression_benchmark.dart
```

Typical performance on modern hardware:
- **Parsing**: ~10,000-50,000 expressions/second
- **Evaluation**: ~100,000-500,000 evaluations/second
- **Async evaluation**: ~1,000-5,000 evaluations/second

## Contributing

Contributions are welcome! Please read the [Contributing Guide](CONTRIBUTING.md) first.

## Security

Please review the [Security Policy](SECURITY.md) before using this library with untrusted input.

## Documentation

📚 Full API documentation is available at **[appsup-dart.github.io/expressions](https://appsup-dart.github.io/expressions/)**

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/appsup-dart/expressions/issues

## Sponsor

Creating and maintaining this package takes a lot of time. If you like the result, please consider to [:heart: sponsor](https://github.com/sponsors/rbellens). 
With your support, I will be able to further improve and support this project.
Also, check out my other dart packages at [pub.dev](https://pub.dev/packages?q=publisher%3Aappsup.be).

