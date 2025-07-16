import Flutter
import UIKit
import GoogleMaps
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase'i başlat
    FirebaseApp.configure()
    
    GMSServices.provideAPIKey("AIzaSyBpvPVP-DSCBjIIjzjP_h71QxPXXZPe7Bc")  // Geçici olarak kapatıldı
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
