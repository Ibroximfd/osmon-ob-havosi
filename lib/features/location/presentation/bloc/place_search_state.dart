part of 'place_search_bloc.dart';

final class PlaceSearchState extends Equatable {
  const PlaceSearchState({
    this.query = '',
    this.status = LoadStatus.initial,
    this.results = const <Place>[],
    this.failure,
  });

  final String query;

  /// `initial` means "no query yet" — the screen shows suggestions.
  final LoadStatus status;
  final List<Place> results;
  final DataFailure? failure;

  bool get hasNoMatches => status == LoadStatus.ready && results.isEmpty;

  @override
  List<Object?> get props => <Object?>[query, status, results, failure];
}
