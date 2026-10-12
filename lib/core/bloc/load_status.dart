/// The states gallery every data screen renders. One meaning each — see the
/// flutter-ui skill: `empty` is "nothing exists yet", `offline` keeps cached
/// content on screen behind a neutral banner.
enum LoadStatus { initial, loading, ready, empty, failure, offline }

extension LoadStatusX on LoadStatus {
  bool get isBusy => this == LoadStatus.initial || this == LoadStatus.loading;
}
