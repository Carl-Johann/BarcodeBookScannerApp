//
//  AppDelegate.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 25/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {//, GIDSignInDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        //GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if error != nil {
//            print("Failed to log into Google", error)
//            return
//        }
//        
//        print("Succesfully signed into Google", user)
//        
//        guard let idToken = user.authentication.idToken else { print("Couldn't get idToken from user"); return }
//        guard let accessToken = user.authentication.accessToken else { print("Couldn't get 'accessToken' from user"); return }
//        
//        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
//        Auth.auth().signIn(with: credentials) { (user, error) in
//            
//            if error != nil {
//                print("Failed to sign in to Firebase with Google")
//                return
//            }
//            
//            print("Successfully logged into Firebase with Google", user!.uid)
//            
//        }
//    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.sourceApplication])
        
        GIDSignIn.sharedInstance().handle(url,
                                          sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                          annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
        
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
    
    
}
