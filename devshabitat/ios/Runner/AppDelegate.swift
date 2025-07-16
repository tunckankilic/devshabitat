import Flutter
import UIKit
import GoogleMaps
import Firebase
import FBSDKCoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase'i başlat
    FirebaseApp.configure()
    
    // Facebook SDK'yı başlat
    ApplicationDelegate.shared.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
    )
    
    GMSServices.provideAPIKey("AIzaSyBpvPVP-DSCBjIIjzjP_h71QxPXXZPe7Bc")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Facebook URL şemasını işle
    if ApplicationDelegate.shared.application(
        app,
        open: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    ) {
        return true
    }
    
    // Diğer URL şemalarını işle
    return super.application(app, open: url, options: options)
  }
}
