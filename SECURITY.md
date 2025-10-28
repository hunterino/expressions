# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 0.2.x   | :white_check_mark: |
| < 0.2.0 | :x:                |

## Reporting a Vulnerability

We take the security of the Expressions library seriously. If you discover a security vulnerability, please follow these steps:

### 1. **Do Not** Open a Public Issue

Please do not create a public GitHub issue for security vulnerabilities, as this could put users at risk.

### 2. Report Privately

Send a detailed report to the maintainer via:
* GitHub Security Advisories (preferred): [Report a vulnerability](https://github.com/appsup-dart/expressions/security/advisories/new)
* Direct email to the maintainer listed in the pubspec.yaml

### 3. Include Details

Your report should include:
* Description of the vulnerability
* Steps to reproduce the issue
* Potential impact and attack scenarios
* Any suggested fixes or mitigations
* Your contact information for follow-up

### 4. Response Timeline

* **Initial Response**: Within 48 hours
* **Status Update**: Within 7 days
* **Fix Timeline**: Depends on severity
  * Critical: Within 7 days
  * High: Within 30 days
  * Medium: Within 90 days
  * Low: Next regular release

## Security Considerations

### Expression Evaluation Safety

The Expressions library evaluates user-provided expressions. When using this library:

#### 1. **Untrusted Input**
```dart
// ⚠️ WARNING: Never eval untrusted expressions without sandboxing
var userInput = getUserInput(); // Could be malicious!
var expr = Expression.parse(userInput);
var result = evaluator.eval(expr, context);
```

**Mitigation:**
* Validate expressions before parsing
* Limit available functions in the context
* Use a restricted context with only safe operations
* Implement timeouts for evaluation
* Consider expression complexity limits

#### 2. **Context Isolation**
```dart
// ✓ GOOD: Provide only necessary context
var safeContext = {
  'x': userValue,
  'abs': (num n) => n.abs(),
  // Only include safe, necessary functions
};

// ✗ BAD: Exposing dangerous functions
var unsafeContext = {
  'eval': eval, // ⚠️ Never do this!
  'exec': Process.run, // ⚠️ Extremely dangerous!
};
```

#### 3. **Denial of Service**
Deep or complex expressions can cause performance issues:

```dart
// Could cause stack overflow or excessive memory use
var deepExpression = '1' + ('+1' * 100000);
```

**Mitigation:**
* Set parsing timeouts
* Limit expression complexity (depth, operator count)
* Use async evaluation with cancellation tokens

#### 4. **Resource Exhaustion**
```dart
// Infinite streams could cause memory leaks
var evaluator = const AsyncExpressionEvaluator();
var result = evaluator.eval(expr, {
  'stream': infiniteStream, // ⚠️ Could exhaust memory
});
```

**Mitigation:**
* Use bounded streams
* Implement proper stream disposal
* Set memory limits for evaluation

### Best Practices

1. **Validate Input**: Always validate and sanitize user input before parsing
2. **Limit Context**: Only include safe, necessary functions and variables
3. **Timeout Operations**: Set reasonable timeouts for expression evaluation
4. **Audit Dependencies**: Regularly check for vulnerabilities in dependencies
5. **Update Regularly**: Keep the library updated to the latest version
6. **Test Security**: Include security test cases in your test suite

### Example: Safe Expression Evaluation

```dart
import 'package:expressions/expressions.dart';

class SafeExpressionEvaluator {
  static const maxExpressionLength = 1000;
  static const allowedVariables = {'x', 'y', 'z'};
  static const allowedFunctions = {'abs', 'min', 'max', 'sqrt'};

  dynamic evalSafe(String expressionString, Map<String, dynamic> userContext) {
    // 1. Validate length
    if (expressionString.length > maxExpressionLength) {
      throw SecurityException('Expression too long');
    }

    // 2. Parse expression
    var expr = Expression.tryParse(expressionString);
    if (expr == null) {
      throw SecurityException('Invalid expression');
    }

    // 3. Validate variables and functions (implement validator)
    validateExpression(expr);

    // 4. Create restricted context
    var safeContext = <String, dynamic>{};
    for (var key in userContext.keys) {
      if (allowedVariables.contains(key)) {
        safeContext[key] = userContext[key];
      }
    }

    // Add only safe functions
    safeContext.addAll({
      'abs': (num n) => n.abs(),
      'min': (num a, num b) => a < b ? a : b,
      'max': (num a, num b) => a > b ? a : b,
      'sqrt': (num n) => n >= 0 ? sqrt(n) : throw ArgumentError('Negative sqrt'),
    });

    // 5. Evaluate with timeout
    const evaluator = ExpressionEvaluator();
    return evaluator.eval(expr, safeContext);
  }

  void validateExpression(Expression expr) {
    // Implement AST validation to check for:
    // - Allowed variables only
    // - Allowed functions only
    // - Expression depth limits
    // - No suspicious patterns
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
}
```

## Known Security Considerations

1. **No Built-in Sandboxing**: This library does not provide built-in sandboxing. Implementers must create their own security boundaries.

2. **Member Access**: The `MemberAccessor` feature can access object properties. Ensure you only expose safe properties.

3. **Function Execution**: Any function in the context can be called. Never include dangerous functions like `eval`, `exec`, or file I/O operations.

## Disclosure Policy

When we receive a security report:

1. We will confirm receipt within 48 hours
2. We will investigate and develop a fix
3. We will not disclose the vulnerability until a fix is available
4. We will credit the reporter (unless they prefer to remain anonymous)
5. We will publish a security advisory when the fix is released

## Security Updates

Security updates are published via:
* GitHub Security Advisories
* CHANGELOG.md with [SECURITY] prefix
* Pub.dev package updates

## Questions?

If you have questions about security that don't involve a specific vulnerability, feel free to open a public issue or discussion.
