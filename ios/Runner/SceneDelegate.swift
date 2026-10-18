import Flutter
import UIKit
import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

    if window == nil, let windowScene = scene as? UIWindowScene {
      window = windowScene.windows.first { $0.rootViewController != nil }
        ?? windowScene.windows.first
    }
    if let window {
      appDelegate.window = window
    }
    appDelegate.registerFlutterPluginsIfReady()
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    (UIApplication.shared.delegate as? AppDelegate)?.registerFlutterPluginsIfReady()
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let context = URLContexts.first else { return }
    var options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    if let sourceApplication = context.options.sourceApplication {
      options[.sourceApplication] = sourceApplication
    }
    if let annotation = context.options.annotation {
      options[.annotation] = annotation
    }
    _ = ApplicationDelegate.shared.application(
      UIApplication.shared,
      open: context.url,
      options: options
    )
  }
}
