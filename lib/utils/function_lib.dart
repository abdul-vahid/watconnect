import '../utils/app_constants.dart';

void debug(message) {
  if (AppConstants.kDebugMode) {
    print(message);
  }
}
