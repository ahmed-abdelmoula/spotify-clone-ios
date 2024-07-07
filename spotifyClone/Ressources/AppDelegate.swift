//
//  AppDelegate.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // this is the windodws that will be created when our application load up
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//         we need to configure which view controller pops up when our app first lunch
        let window = UIWindow(frame: UIScreen.main.bounds)
        if AuthManager.shared.isSingedIn {
            // instead of waiting to refreshToken when APICall withValidToken
            // we will change so when user is signed we refresh the token if needed
            // but we don't want a completion handler for it after completion
            // because we don't not gonna check if token is refresh or not
            // that why as soon as our app is launched it will start refreshing token if needed
            AuthManager.shared.refreshAccesTokenIfNeccessary(completion: nil)
            window.rootViewController = TabBarViewController()
        } else {
            
            let nvC = UINavigationController(rootViewController: WelcomeViewController())
            nvC.navigationBar.prefersLargeTitles = true
            nvC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
            window.rootViewController = nvC
        }
        window.makeKeyAndVisible()
        self.window = window
       // print(AuthManager.shared.signInUrl?.absoluteString)
//        AuthManager.shared.refreshAccesTokenIfNeccessary { sucess in
//            print("helos  : \(sucess)")
//        }
//        AuthManager.shared.withValidToken { token in
//            print(token)
//        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

