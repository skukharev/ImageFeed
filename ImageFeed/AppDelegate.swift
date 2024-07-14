//
//  AppDelegate.swift
//  imageFeed
//
//  Created by Сергей Кухарев on 05.05.2024.
//

import UIKit
import Kingfisher
import ProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Настройки глобального кэша Kingfisher
        let cache = ImageCache.default
        cache.memoryStorage.config.countLimit = 150
        cache.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
        cache.memoryStorage.config.expiration = .days(1)
        cache.diskStorage.config.expiration = .days(7)

        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = .black
        ProgressHUD.colorAnimation = .lightGray

        loadRocketSimConnect()

        return true
    }

    private func loadRocketSimConnect() {
        #if DEBUG
        guard Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true else {
            return
        }
        print("RocketSim Connect successfully linked")
        #endif
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
