import Flutter
import UIKit
import google_mobile_ads
import workmanager_apple

private let nativeAdFactoryId = "listTile"

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Background refresh (rain alerts, widget, prayer reminders). The
    // identifier must match BackgroundRefresh in Dart and Info.plist.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "uz.osmon.refresh",
      frequency: NSNumber(value: 60 * 60)
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: nativeAdFactoryId,
      nativeAdFactory: ListTileNativeAdFactory()
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
