class ValidationError implements Exception {
  final String message;
  final String? field;
  final dynamic value;
  final String? code;

  ValidationError(this.message, {this.field, this.value, this.code});

  @override
  String toString() => message;
}
