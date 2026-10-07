import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var didRegisterPlugins = false

  func registerFlutterPluginsIfReady() {
    guard !didRegisterPlugins else { return }
    guard window?.rootViewController is FlutterViewController else { return }
    GeneratedPluginRegistrant.register(with: self)
    didRegisterPlugins = true
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAdGQ36aP1VwJbXAkvvdsX8A95DxbJAIvY")
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    registerFlutterPluginsIfReady()
    return result
  }
}
