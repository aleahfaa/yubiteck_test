import '../error/failures.dart';
import '../network/result.dart';

abstract interface class UseCase<R, Params> {
  Future<Result<Failure, R>> call(Params params);
}

final class NoParams {
  const NoParams();
}
