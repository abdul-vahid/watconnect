import 'dart:convert';

String replacePlaceholders(String messageBody, String? bodyTextParamsString) {
  print("bodyTextParamsString:::::::::::::: $bodyTextParamsString");

  if (bodyTextParamsString == null || bodyTextParamsString.isEmpty) {
    return messageBody;
  }

  try {
    // Convert Dart-style map string to JSON-style string
    final fixedString = bodyTextParamsString
        .replaceAllMapped(RegExp(r'(\w+):'), (match) => '"${match[1]}":')
        .replaceAllMapped(RegExp(r':\s*([^,}]+)'), (match) {
      final value = match[1]!.trim();
      // If it's already quoted, number, or boolean/null, keep as is
      if (value.startsWith('"') ||
          value == 'null' ||
          value == 'true' ||
          value == 'false' ||
          num.tryParse(value) != null) {
        return ': $value';
      }
      return ': "$value"'; // wrap in quotes if plain word
    });

    final Map<String, dynamic> params = jsonDecode(fixedString);

    params.forEach((key, value) {
      messageBody = messageBody.replaceAll('{{$key}}', value.toString());
    });
  } catch (e) {
    print('Error decoding or replacing placeholders: $e');
  }

  return messageBody;
}
