/// Source location information for expressions.
///
/// This helps provide better error messages by tracking where in the
/// source string an expression was parsed from.
class SourceLocation {
  /// The starting position in the source string (0-based).
  final int start;

  /// The ending position in the source string (0-based, exclusive).
  final int end;

  /// The original source string.
  final String source;

  /// Creates a source location.
  const SourceLocation(this.start, this.end, this.source);

  /// The line number (1-based) where this location starts.
  int get line {
    var lineNum = 1;
    for (var i = 0; i < start && i < source.length; i++) {
      if (source[i] == '\n') lineNum++;
    }
    return lineNum;
  }

  /// The column number (1-based) where this location starts.
  int get column {
    var col = 1;
    for (var i = start - 1; i >= 0 && i < source.length; i--) {
      if (source[i] == '\n') break;
      col++;
    }
    return col;
  }

  /// The substring of the source at this location.
  String get text {
    if (start < 0 || end > source.length || start > end) {
      return '';
    }
    return source.substring(start, end);
  }

  /// Returns a human-readable representation of this location.
  @override
  String toString() => 'line $line, column $column';

  /// Returns a detailed error message with context.
  String formatError(String message) {
    var buffer = StringBuffer();
    buffer.writeln(message);
    buffer.writeln('  at $this');

    // Show the line with the error
    var lineStart = start;
    while (lineStart > 0 && source[lineStart - 1] != '\n') {
      lineStart--;
    }

    var lineEnd = end;
    while (lineEnd < source.length && source[lineEnd] != '\n') {
      lineEnd++;
    }

    var errorLine = source.substring(lineStart, lineEnd);
    buffer.writeln('  $errorLine');

    // Show a caret pointing to the error
    var caretPos = start - lineStart;
    var caretLength = (end - start).clamp(1, 80);
    buffer.write('  ${' ' * caretPos}${'^' * caretLength}');

    return buffer.toString();
  }
}
