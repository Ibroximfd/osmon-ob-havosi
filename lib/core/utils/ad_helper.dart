import 'dart:io';

// TEST MODE: emulator/debug uchun rasmiy test ID lari
// Production buildga o'tishda _testMode = false qiling
const bool _testMode = false;

class AdHelper {
  static String get bannerAdUnitId {
    if (_testMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-3940256099942544/6300978111';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-2122406741205447/6134414106';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2122406741205447/6134414106';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get openAppAdUnitId {
    if (_testMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/5575463023'
          : 'ca-app-pub-3940256099942544/9257395921';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-2122406741205447/1006210508';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2122406741205447/1006210508';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
