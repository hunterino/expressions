---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Description
A clear and concise description of what the bug is.

## Steps to Reproduce
Steps to reproduce the behavior:
1. Parse expression '...'
2. Create context with '...'
3. Call evaluator with '...'
4. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
What actually happened. Include error messages if applicable.

## Code Example
```dart
// Minimal code example that reproduces the issue
import 'package:expressions/expressions.dart';

void main() {
  var expr = Expression.parse('...');
  var evaluator = const ExpressionEvaluator();
  var result = evaluator.eval(expr, {...});
  print(result); // Expected: X, Actual: Y
}
```

## Environment
* **Dart SDK version**: (run `dart --version`)
* **Package version**: (check pubspec.yaml)
* **Operating System**: (e.g., macOS 12.0, Ubuntu 20.04, Windows 11)

## Additional Context
Add any other context about the problem here, such as:
* Does it work in previous versions?
* Are there any error stack traces?
* Any workarounds you've found?

## Possible Solution
If you have ideas on how to fix this, please share them here.
