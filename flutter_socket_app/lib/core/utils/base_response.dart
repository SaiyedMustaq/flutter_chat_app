class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  BaseResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['statusCode'] ?? 200,
    );
  }
}
