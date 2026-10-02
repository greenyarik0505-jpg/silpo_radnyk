/// Generic Result wrapper for functional error handling in services and repositories.
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull => switch (this) {
    ApiSuccess(data: final d) => d,
    ApiFailure() => null,
  };

  String? get errorOrNull => switch (this) {
    ApiSuccess() => null,
    ApiFailure(message: final m) => m,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  }) {
    return switch (this) {
      ApiSuccess(data: final d) => success(d),
      ApiFailure(message: final m, statusCode: final code) => failure(m, code),
    };
  }
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

final class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final dynamic cause;

  const ApiFailure(this.message, {this.statusCode, this.cause});
}
