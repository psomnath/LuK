//
//  SceneDelegate.swift
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        let amberAlertsTableViewController = AmberAlertsTableViewController()
        UNUserNotificationCenter.current().delegate = amberAlertsTableViewController
        
        let navigationViewController = UINavigationController(rootViewController: amberAlertsTableViewController)
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
    }
}
