import Flutter
import UIKit
import Firebase
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Firebase'i initialize et
    FirebaseApp.configure()
    
    // Google Maps API Key'i Info.plist'ten al ve configure et
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let plist = NSDictionary(contentsOfFile: path),
       let apiKey = plist["GoogleMapsAPIKey"] as? String {
      GMSServices.provideAPIKey(apiKey)
    }
    
    // Flutter plugin'lerini kaydet - Firebase ve Google Maps da dahil
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // OAuth URL şemalarını işle (GitHub, Google, Apple Sign-In)
    return super.application(app, open: url, options: options)
  }
}