import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/ads/ad_config.dart';

void main() {
  test('Google sample units never serve in a release configuration', () {
    expect(AdConfig.testMode, isFalse);
    expect(
      AdConfig.isServable('ca-app-pub-3940256099942544/1033173712'),
      isFalse,
    );
    expect(AdConfig.isServable(''), isFalse);
    expect(
      AdConfig.isServable('ca-app-pub-2122406741205447/7857642355'),
      isTrue,
    );
  });
}
