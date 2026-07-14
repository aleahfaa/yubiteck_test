sealed class ViewState<T> {
  const ViewState();
}

final class ViewIdle<T> extends ViewState<T> {
  const ViewIdle();
}

final class ViewLoading<T> extends ViewState<T> {
  const ViewLoading();
}

final class ViewLoaded<T> extends ViewState<T> {
  final T data;
  const ViewLoaded(this.data);
}

final class ViewEmpty<T> extends ViewState<T> {
  final String? message;
  const ViewEmpty({this.message});
}

final class ViewFailure<T> extends ViewState<T> {
  final String message;
  const ViewFailure(this.message);
}
