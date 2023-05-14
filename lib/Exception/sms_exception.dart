class SmsException implements Exception {
  SmsException({required this.code, required this.details});
  final String code;
  final String details;
}
