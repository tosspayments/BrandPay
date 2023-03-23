//
//  AppDelegate.swift
//  BrandPayWebInterface
//
//  Created by 김진규 on 2021/11/26.
//  Copyright © 2021 com.tosspayments. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        let viewController = UIViewController()
        
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let demoVC = BrandPayWebInterfaceDemoViewController()
            self.window?.rootViewController?.present(UINavigationController(rootViewController: demoVC), animated: true)
        }
        self.window = window
            
        return true
    }

}

