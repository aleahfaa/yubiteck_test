import '../error/exceptions.dart';
import '../error/failures.dart';
import 'result.dart';

Future<Result<Failure, T>> guardResult<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on NetworkException catch (e) {
    return Err(NetworkFailure(e.message));
  } on AuthException catch (e) {
    return Err(AuthFailure(e.message));
  } on ServerException catch (e) {
    return Err(ServerFailure(e.message, statusCode: e.statusCode));
  } on CacheException catch (e) {
    return Err(CacheFailure(e.message));
  } catch (e) {
    return Err(UnknownFailure(e.toString()));
  }
}
