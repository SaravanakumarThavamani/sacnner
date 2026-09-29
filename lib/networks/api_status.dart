class SuccessStatus {
  String responseStr;
  int statusCode;
  SuccessStatus({required this.statusCode, required this.responseStr});
}

class FailureStatus {
  String message;
  int statusCode;
  FailureStatus({required this.statusCode, required this.message});
}
