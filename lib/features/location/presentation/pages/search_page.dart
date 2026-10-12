import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../bloc/place_search_bloc.dart';
import '../widgets/search_view.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.pickOnly = false});

  /// Return the chosen place to the caller (route planner) instead of
  /// switching the app's city.
  final bool pickOnly;

  @override
  Widget build(BuildContext context) => BlocProvider<PlaceSearchBloc>(
    create: (_) => sl<PlaceSearchBloc>(),
    child: SearchView(pickOnly: pickOnly),
  );
}
