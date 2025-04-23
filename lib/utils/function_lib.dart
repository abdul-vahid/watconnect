import '../utils/app_constants.dart';

void debug(message) {
  if (AppConstants.kDebugMode) {
    print(message);
  }
}

void debugLog(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
