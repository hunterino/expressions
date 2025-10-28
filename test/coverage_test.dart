import 'package:expressions/expressions.dart';
import 'package:test/test.dart';

/// Additional tests to increase code coverage
void main() {
  group('Coverage - Edge Cases', () {
    const evaluator = ExpressionEvaluator();

    test('string escape in Literal._escapeString', () {
      var tests = {
        'hello\\world': r'hello\\world',
        'hello"world': r'hello\"world',
        'hello\nworld': r'hello\nworld',
        'hello\rworld': r'hello\rworld',
        'hello\tworld': r'hello\tworld',
        'hello\bworld': r'hello\bworld',
        'hello\fworld': r'hello\fworld',
      };

      tests.forEach((input, expected) {
        var lit = Literal(input);
        expect(lit.raw, '"$expected"');
      });
    });

    test('Literal toString and equality', () {
      var lit1 = Literal(42);
      var lit2 = Literal(42);
      var lit3 = Literal(43);

      expect(lit1.toString(), '42');
      expect(lit1 == lit2, isTrue);
      expect(lit1 == lit3, isFalse);
      expect(lit1 == Object(), isFalse);
      expect(lit1.hashCode, lit2.hashCode);
    });

    test('BinaryExpression precedence and toString', () {
      var add = BinaryExpression('+', Literal(1), Literal(2));
      var mul = BinaryExpression('*', Literal(3), Literal(4));
      var combined = BinaryExpression('+', add, mul);

      expect(combined.toString(), '1+2+3*4'); // No parens needed since + has lower precedence
      expect(BinaryExpression.precedenceForOperator('+'), 9);
      expect(BinaryExpression.precedenceForOperator('*'), 10);
    });

    test('BinaryExpression equality and hashCode', () {
      var expr1 = BinaryExpression('+', Literal(1), Literal(2));
      var expr2 = BinaryExpression('+', Literal(1), Literal(2));
      var expr3 = BinaryExpression('-', Literal(1), Literal(2));

      expect(expr1 == expr2, isTrue);
      expect(expr1 == expr3, isFalse);
      expect(expr1.hashCode, expr2.hashCode);
    });

    test('all binary operators', () {
      var operators = {
        '??': (1, null, 1),
        '||': (true, false, true),
        '&&': (true, false, false),
        '|': (5, 3, 7),
        '^': (5, 3, 6),
        '&': (5, 3, 1),
        '==': (5, 5, true),
        '!=': (5, 3, true),
        '<=': (3, 5, true),
        '>=': (5, 3, true),
        '<': (3, 5, true),
        '>': (5, 3, true),
        // Note: << and >> not tested with spaces due to parser ambiguity
        '+': (5, 3, 8),
        '-': (5, 3, 2),
        '*': (5, 3, 15),
        '/': (6, 3, 2),
        '%': (5, 3, 2),
        '~/': (7, 3, 2),
      };

      operators.forEach((op, values) {
        var (left, right, expected) = values;
        var expr = Expression.parse('a $op b');
        var result = evaluator.eval(expr, {'a': left, 'b': right});
        expect(result, expected, reason: 'Operator $op failed');
      });
    });

    test('all unary operators', () {
      var tests = {
        '-5': -5,
        '+5': 5,
        '!true': false,
        '!false': true,
        '~5': ~5,
      };

      tests.forEach((expr, expected) {
        var result = evaluator.eval(Expression.parse(expr), {});
        expect(result, expected);
      });
    });

    test('Unknown unary operator throws', () {
      var expr = UnaryExpression('%', Literal(5));
      expect(() => evaluator.eval(expr, {}), throwsArgumentError);
    });

    test('Unknown binary operator throws', () {
      var expr = BinaryExpression('**', Literal(2), Literal(3));
      expect(() => evaluator.eval(expr, {}), throwsArgumentError);
    });

    test('Unknown expression type throws', () {
      var expr = _CustomExpression();
      expect(() => evaluator.eval(expr, {}), throwsArgumentError);
    });

    test('MemberExpression with MemberAccessor.mapAccessor', () {
      var evaluator = const ExpressionEvaluator(
          memberAccessors: [MemberAccessor.mapAccessor]);
      var expr = Expression.parse('obj.key');
      var result = evaluator.eval(expr, {
        'obj': {'key': 'value'}
      });
      expect(result, 'value');
    });

    test('MemberExpression without accessor throws', () {
      var expr = Expression.parse('obj.prop');
      expect(
          () => evaluator.eval(expr, {
                'obj': _TestObject()
              }),
          throwsA(isA<ExpressionEvaluatorException>()));
    });

    test('Nested array and map literals', () {
      var expr = Expression.parse('[1, [2, 3], {"a": 4}]');
      var result = evaluator.eval(expr, {});
      expect(result, [
        1,
        [2, 3],
        {'a': 4}
      ]);
    });

    test('Variable toString', () {
      var v = Variable(Identifier('myVar'));
      expect(v.toString(), 'myVar');
    });

    test('MemberExpression toString', () {
      var expr =
          MemberExpression(Variable(Identifier('obj')), Identifier('prop'));
      expect(expr.toString(), 'obj.prop');
    });

    test('IndexExpression toString', () {
      var expr = IndexExpression(Variable(Identifier('arr')), Literal(0));
      expect(expr.toString(), 'arr[0]');
    });

    test('CallExpression toString', () {
      var expr = CallExpression(
          Variable(Identifier('func')), [Literal(1), Literal(2)]);
      expect(expr.toString(), 'func(1, 2)');
    });

    test('UnaryExpression toString', () {
      var expr = UnaryExpression('-', Literal(5));
      expect(expr.toString(), '-5');
    });

    test('ConditionalExpression toString', () {
      var expr = ConditionalExpression(
          Literal(true), Literal('yes'), Literal('no'));
      expect(expr.toString(), 'true ? "yes" : "no"');
    });

    test('Identifier with reserved words throws assertion', () {
      expect(() => Identifier('null'), throwsA(isA<AssertionError>()));
      expect(() => Identifier('true'), throwsA(isA<AssertionError>()));
      expect(() => Identifier('false'), throwsA(isA<AssertionError>()));
      expect(() => Identifier('this'), throwsA(isA<AssertionError>()));
    });

    test('Identifier toString', () {
      var id = Identifier('myId');
      expect(id.toString(), 'myId');
    });

    test('toTokenString for simple and compound expressions', () {
      var simple = Literal(5);
      var compound = BinaryExpression('+', Literal(1), Literal(2));

      expect(simple.toTokenString(), '5');
      expect(compound.toTokenString(), '(1+2)');
    });

    test('ExpressionEvaluatorException toString', () {
      var ex = ExpressionEvaluatorException('test message');
      expect(ex.toString(), 'ExpressionEvaluatorException: test message');

      var ex2 = ExpressionEvaluatorException.memberAccessNotSupported(
          String, 'length');
      expect(ex2.toString(), contains('String'));
      expect(ex2.toString(), contains('length'));
    });

    test('Nested binary expressions with different precedence', () {
      var expr = Expression.parse('1 + 2 * 3 - 4 / 2');
      var result = evaluator.eval(expr, {});
      expect(result, 1 + 2 * 3 - 4 / 2);
    });

    test('Bitwise operators', () {
      var tests = {
        '5 & 3': 1,
        '5 | 3': 7,
        '5 ^ 3': 6,
        // Note: << and >> require spaces to avoid parser conflicts
      };

      tests.forEach((expr, expected) {
        var result = evaluator.eval(Expression.parse(expr), {});
        expect(result, expected);
      });
    });

    test('Logical operators short-circuit', () {
      var callCount = 0;
      bool sideEffect() {
        callCount++;
        return true;
      }

      // Test && short-circuit
      callCount = 0;
      var expr1 = Expression.parse('false && f()');
      evaluator.eval(expr1, {'f': sideEffect});
      expect(callCount, 0); // f() should not be called

      // Test || short-circuit
      callCount = 0;
      var expr2 = Expression.parse('true || f()');
      evaluator.eval(expr2, {'f': sideEffect});
      expect(callCount, 0); // f() should not be called

      // Test ?? short-circuit
      callCount = 0;
      var expr3 = Expression.parse('5 ?? f()');
      evaluator.eval(expr3, {'f': sideEffect});
      expect(callCount, 0); // f() should not be called
    });

    test('Parser handles scientific notation', () {
      // Test basic scientific notation support
      var expr1 = Expression.parse('1e3');
      expect(evaluator.eval(expr1, {}), 1000);

      var expr2 = Expression.parse('1E-3');
      expect(evaluator.eval(expr2, {}), 0.001);
    });
  });
}

class _CustomExpression implements Expression {
  @override
  String toTokenString() => 'custom';
}

class _TestObject {}
