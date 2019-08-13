//
//  AppDelegate.swift
//  TestLambda
//
//  Created by Victor on 2019/7/1.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import FacebookCore
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let FACEBOOK_SCHEME = "[YOUR APP FACEBOOK URL SCHEME]"
    let GOOGLE_SCHEME = "[YOUR APP GOOGLE URL SCHEME]"
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // AWS cognito federated settings
        APISession.shared.setConfiguration()
        setEntryWindow()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == FACEBOOK_SCHEME {
            return SDKApplicationDelegate.shared.application(app, open: url,options:options)
        }else if url.scheme == GOOGLE_SCHEME {
            return GIDSignIn.sharedInstance().handle(url as URL?,
                                                     sourceApplication: options[.sourceApplication] as? String,
                                                     annotation: options[.annotation])
        }
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func setEntryWindow() {
        var initialViewController: UIViewController!
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        initialViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        if isLogin {
            let detailViewControoler = storyboard.instantiateViewController(withIdentifier: "DetailViewController")
            initialViewController.present(detailViewControoler, animated: false)
        }
        
    }

}
