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
    
    // Google Maps API Key'i Info.plist'ten oku (güvenli yöntem)
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let plist = NSDictionary(contentsOfFile: path),
       let googleMapsApiKey = plist["AIzaSyBpvPVP-DSCBjIIjzjP_h71QxPXXZPe7Bc"] as? String {
      GMSServices.provideAPIKey(googleMapsApiKey)
    } else {
      // Fallback - direkt key (geçici)
      GMSServices.provideAPIKey("AIzaSyBpvPVP-DSCBjIIjzjP_h71QxPXXZPe7Bc")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // GitHub OAuth ve diğer URL şemalarını işle
    return super.application(app, open: url, options: options)
  }
}