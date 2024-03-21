import '../services/success.dart';
import 'Failure.dart';

abstract class Result {}

class SuccessResult implements Result {
  final Success success;
  SuccessResult(this.success);
}

class FailureResult implements Result {
  final Failure failure;
  FailureResult(this.failure);
}

extension ResultExtension on Result {
  bool get isSuccess => this is SuccessResult;
  bool get isFailure => this is FailureResult;
  Success get successValue => (this as SuccessResult).success;
  Failure get failureValue => (this as FailureResult).failure;
  bool get isNotResult => this is! Result;

  static SuccessResult createSuccessResult(String message) => SuccessResult(Success(message));
  static FailureResult createFailureResult(String message) => FailureResult(Failure(message));
}