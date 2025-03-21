import '../../core/apis/api_response.dart';

class AppException implements Exception {
  // ignore: prefer_typing_uninitialized_variables
  final _message;
  // ignore: prefer_typing_uninitialized_variables
  final _prefix;
  int? statusCode;
  AppException([this._message, this._prefix, this.statusCode]);

  @override
  String toString() {
    return "$_prefix$_message";
  }

  dynamic getMessage() => _message;
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(
            message, "Error During Communication: ", ApiResponse.internalError);
}

class BadRequestException extends AppException {
  BadRequestException([message])
      : super(message, "InvalidRequest: ", ApiResponse.badRequest);
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message])
      : super(
            message, "Unauthorised Request: ", ApiResponse.unAuthorizedRequest);
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message])
      : super(message, "Invalid Input: ", ApiResponse.badRequest);
}
