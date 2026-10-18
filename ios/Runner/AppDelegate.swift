import Flutter
import UIKit
import GoogleMaps
import FBSDKCoreKit

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
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    registerFlutterPluginsIfReady()
    return result
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if ApplicationDelegate.shared.application(app, open: url, options: options) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
