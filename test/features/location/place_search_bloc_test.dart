import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/bloc/load_status.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/location/presentation/bloc/place_search_bloc.dart';

import '../../helpers/fakes.dart';

void main() {
  PlaceSearchBloc build() => PlaceSearchBloc(
    FakePlaceSearch(<String, List<Place>>{
      'Sam': <Place>[UzbekCities.regionalCentres[1]],
    }),
    FakeSettingsRepository(),
    debounce: Duration.zero,
  );

  blocTest<PlaceSearchBloc, PlaceSearchState>(
    'a match comes back ready',
    build: build,
    act: (bloc) => bloc.add(const PlaceQueryChanged('Sam')),
    wait: const Duration(milliseconds: 20),
    expect: () => <PlaceSearchState>[
      const PlaceSearchState(query: 'Sam', status: LoadStatus.loading),
      PlaceSearchState(
        query: 'Sam',
        status: LoadStatus.ready,
        results: <Place>[UzbekCities.regionalCentres[1]],
      ),
    ],
  );

  blocTest<PlaceSearchBloc, PlaceSearchState>(
    'no match is no-results, not an error',
    build: build,
    act: (bloc) => bloc.add(const PlaceQueryChanged('Zzz')),
    wait: const Duration(milliseconds: 20),
    verify: (bloc) => expect(bloc.state.hasNoMatches, isTrue),
  );

  blocTest<PlaceSearchBloc, PlaceSearchState>(
    'one letter does not search',
    build: build,
    act: (bloc) => bloc.add(const PlaceQueryChanged('S')),
    wait: const Duration(milliseconds: 20),
    expect: () => <PlaceSearchState>[const PlaceSearchState(query: 'S')],
  );
}
