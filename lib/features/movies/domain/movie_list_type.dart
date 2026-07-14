enum MovieListType {
  popular('Popular'),
  nowPlaying('Now Playing'),
  topRated('Top Rated'),
  upcoming('Upcoming');

  final String label;
  const MovieListType(this.label);
}
