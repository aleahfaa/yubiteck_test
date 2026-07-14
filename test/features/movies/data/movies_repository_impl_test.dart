import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yubiteck_test/core/error/exceptions.dart';
import 'package:yubiteck_test/core/error/failures.dart';
import 'package:yubiteck_test/core/network/result.dart';
import 'package:yubiteck_test/features/movies/data/movie_detail_model.dart';
import 'package:yubiteck_test/features/movies/data/paginated_movies_model.dart';
import 'package:yubiteck_test/features/movies/data/movies_repository_impl.dart';
import 'package:yubiteck_test/features/movies/domain/movie_list_type.dart';

import '../../../helpers/mock_helpers.dart';

void main() {
  late MockMoviesRemoteDataSource remote;
  late MoviesRepositoryImpl repository;

  setUp(() {
    remote = MockMoviesRemoteDataSource();
    repository = MoviesRepositoryImpl(remote);
  });

  const emptyPage = PaginatedMoviesModel(
    page: 1,
    results: [],
    totalPages: 1,
    totalResults: 0,
  );

  test('returns Ok with the paginated movies on success', () async {
    when(
      () => remote.getMovies(type: MovieListType.popular, page: 1),
    ).thenAnswer((_) async => emptyPage);

    final result = await repository.getMovies(
      type: MovieListType.popular,
      page: 1,
    );

    expect(result, isA<Ok<Failure, dynamic>>());
    expect(result.valueOrNull, emptyPage);
  });

  test('maps NetworkException to NetworkFailure', () async {
    when(
      () => remote.getMovies(type: MovieListType.popular, page: 1),
    ).thenThrow(const NetworkException());

    final result = await repository.getMovies(
      type: MovieListType.popular,
      page: 1,
    );

    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('maps ServerException to ServerFailure with status code', () async {
    when(
      () => remote.getMovies(type: MovieListType.popular, page: 1),
    ).thenThrow(const ServerException('boom', statusCode: 500));

    final result = await repository.getMovies(
      type: MovieListType.popular,
      page: 1,
    );

    final failure = result.failureOrNull;
    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).statusCode, 500);
  });

  test('getMovieDetail returns Ok with the parsed detail on success', () async {
    const detail = MovieDetailModel(
      id: 27205,
      title: 'Inception',
      overview: '',
    );
    when(() => remote.getMovieDetail(27205)).thenAnswer((_) async => detail);

    final result = await repository.getMovieDetail(27205);

    expect(result.valueOrNull, detail);
  });

  test('getMovieDetail maps AuthException to AuthFailure', () async {
    when(
      () => remote.getMovieDetail(27205),
    ).thenThrow(const AuthException('no session'));

    final result = await repository.getMovieDetail(27205);

    expect(result.failureOrNull, isA<AuthFailure>());
  });
}
