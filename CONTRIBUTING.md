# Contributing to Expressions

Thank you for your interest in contributing to the Expressions library! This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps to reproduce the problem**
* **Provide specific examples** - Include code snippets or test cases
* **Describe the behavior you observed** and what you expected to see
* **Include Dart/Flutter version information**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

* **Use a clear and descriptive title**
* **Provide a detailed description of the suggested enhancement**
* **Explain why this enhancement would be useful**
* **List any alternative solutions or features you've considered**

### Pull Requests

1. **Fork the repository** and create your branch from `master`
2. **Make your changes** following the coding standards below
3. **Add tests** for any new functionality
4. **Ensure all tests pass** by running `dart test`
5. **Update documentation** if you're changing functionality
6. **Run the linter** with `dart analyze`
7. **Format your code** with `dart format .`
8. **Write a clear commit message** describing your changes

## Development Setup

```bash
# Clone the repository
git clone https://github.com/appsup-dart/expressions.git
cd expressions

# Install dependencies
dart pub get

# Run tests
dart test

# Run analysis
dart analyze

# Format code
dart format .

# Generate documentation
dart doc
```

## Coding Standards

### Dart Style Guide

* Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
* Use `dart format` to ensure consistent formatting
* Maximum line length: 80 characters (enforced by formatter)

### Documentation

* All public APIs must have dartdoc comments
* Include examples in documentation for complex features
* Use `///` for documentation comments
* Link to related classes using `[ClassName]` syntax

Example:
```dart
/// Parses an expression string and returns the parsed [Expression].
///
/// Throws a [ParserException] if the string cannot be parsed.
///
/// Example:
/// ```dart
/// var expr = Expression.parse('x + y * 2');
/// ```
static Expression parse(String formattedString) { ... }
```

### Testing

* Write tests for all new features and bug fixes
* Aim for 95%+ code coverage
* Use descriptive test names that explain what is being tested
* Group related tests using `group()`
* Test edge cases and error conditions

Example:
```dart
group('Expression.parse', () {
  test('parses simple arithmetic expressions', () {
    var expr = Expression.parse('1 + 2');
    expect(expr, isA<BinaryExpression>());
  });

  test('throws on invalid input', () {
    expect(() => Expression.parse('1 +'), throwsA(isA<ParserException>()));
  });
});
```

### Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable prefix:
  * `feat:` - New feature
  * `fix:` - Bug fix
  * `docs:` - Documentation changes
  * `test:` - Adding or updating tests
  * `refactor:` - Code refactoring
  * `perf:` - Performance improvements
  * `chore:` - Maintenance tasks

Example:
```
feat: add support for null-coalescing operator

Implements the ?? operator for handling null values in expressions.
This allows expressions like 'x ?? defaultValue'.

Closes #123
```

## Architecture Guidelines

When contributing to the codebase, keep these architectural principles in mind:

### Parser Layer
* Use PetitParser combinators for grammar definition
* Keep parser logic declarative and composable
* Add new operators to the precedence map in `binaryOperations`

### Expression AST
* Create specific expression classes for new syntax
* Extend `SimpleExpression` or `CompoundExpression` as appropriate
* Implement `toString()` to regenerate valid source code

### Evaluator Layer
* Add `eval*` methods for new expression types
* Handle both sync and async evaluation in parallel
* Use the visitor pattern consistently
* Protect evaluation methods with `@protected` annotation

## Release Process

Releases are managed by maintainers using [melos](https://melos.invertase.dev/):

```bash
# Version and publish (runs tests automatically)
melos version
```

## Getting Help

* Check the [README](README.md) and [documentation](https://pub.dev/documentation/expressions/latest/)
* Review the [CLAUDE.md](CLAUDE.md) file for architecture overview
* Open an issue for questions or discussions
* Join discussions in existing issues and PRs

## License

By contributing to Expressions, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE)).

## Recognition

Contributors are recognized in release notes and the project README. Thank you for helping make Expressions better!
