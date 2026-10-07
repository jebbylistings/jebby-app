import Flutter
import UIKit

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
}
