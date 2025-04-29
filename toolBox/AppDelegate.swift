//
//  AppDelegate.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        setupMainInterface()
        return true
    }
    
    // MARK: - 设置主界面
    func setupMainInterface() {
        // 创建主界面控制器
        let mainTabBarController = HomeTabbar()
        // 设置为根视图控制器
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()
    }
}

