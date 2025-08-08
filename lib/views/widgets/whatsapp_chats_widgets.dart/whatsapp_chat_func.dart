// ignore_for_file: avoid_print

import 'dart:convert';

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

String replacePlaceholders(String messageBody, String? bodyTextParamsString) {
  print("Incoming messageBody: $messageBody");
  print("Incoming bodyTextParamsString: $bodyTextParamsString");

  if (bodyTextParamsString == null || bodyTextParamsString.isEmpty) {
    print(
        "bodyTextParamsString is null or empty. Returning original messageBody.");
    return messageBody;
  }

  try {
    // Try decoding as JSON directly
    Map<String, dynamic> params = jsonDecode(bodyTextParamsString);

    for (var entry in params.entries) {
      final key = entry.key;
      final value = entry.value;

      // Skip keys that are not string-number based placeholders
      if (!RegExp(r'^\d+$').hasMatch(key)) continue;

      final placeholder = '{{$key}}';
      final replacement = value?.toString() ?? '';
      messageBody = messageBody.replaceAll(placeholder, replacement);
    }
  } catch (e) {
    log("Error decoding bodyTextParamsString: $e          $messageBody   $bodyTextParamsString  ");
    // Optional: Show a fallback message or keep the original
    return messageBody;
  }

  return messageBody;
}
