import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9217530480544704/7074692424';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9217530480544704/7074692424';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get openAppAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9217530480544704/5347366148';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9217530480544704/5347366148';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
