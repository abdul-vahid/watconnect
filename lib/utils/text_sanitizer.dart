class TextSanitizer {
  static String sanitize(String? input, {String replacement = '\uFFFD'}) {
    if (input == null || input.isEmpty) return '';

    final buffer = StringBuffer();
    final codeUnits = input.codeUnits;

    for (var i = 0; i < codeUnits.length; i++) {
      final unit = codeUnits[i];

      if (_isHighSurrogate(unit)) {
        if (i + 1 < codeUnits.length && _isLowSurrogate(codeUnits[i + 1])) {
          buffer.writeCharCode(unit);
          buffer.writeCharCode(codeUnits[i + 1]);
          i++;
        } else {
          buffer.write(replacement);
        }
      } else if (_isLowSurrogate(unit)) {
        buffer.write(replacement);
      } else {
        buffer.writeCharCode(unit);
      }
    }

    return buffer.toString();
  }

  static bool _isHighSurrogate(int unit) => unit >= 0xD800 && unit <= 0xDBFF;

  static bool _isLowSurrogate(int unit) => unit >= 0xDC00 && unit <= 0xDFFF;
}
