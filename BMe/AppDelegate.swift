//
//  AppDelegate.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Connect Firebase when your app starts up
        FIRApp.configure()
                
        // Add notification send user back to login screen after logout
        NotificationCenter.default.addObserver(self, selector: #selector(presentLoginViewController), name: NSNotification.Name(rawValue: Constants.NotificationKeys.didSignOut), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentHomeViewController), name: NSNotification.Name(rawValue: Constants.NotificationKeys.didSignIn), object: nil)
        // Override point for customization after application launch.
        // Sets background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        
        return true
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

    func presentLoginViewController() {
        let storyboard = UIStoryboard.init(name: Constants.OnLogout.StoryboardID, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: Constants.OnLogout.RootViewController)
        UIView.transition(with: window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: {
            self.window?.rootViewController = rootVC
        }) { (success: Bool) in
            //completion code
        }
    }
    func presentHomeViewController(){
        let storyboard = UIStoryboard.init(name: Constants.OnLogin.StoryboardID, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: Constants.OnLogin.RootViewController)
        UIView.transition(with: window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: {
            self.window?.rootViewController = rootVC
        }) { (success: Bool) in
            //completion code
        }
        
    }

    class func urlForNewDocumentFile(named: String) -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let filePath = documentsPath.strings(byAppendingPaths: [named])[0]
        let url = URL(fileURLWithPath: filePath)
        
        if(FileManager.default.fileExists(atPath: url.path)){
            do{
                try FileManager.default.removeItem(at: url)
                print("Deleted video file at \(url.path)")
            }catch let error as NSError {
                print("Error- deleting video file at \(url.path): \(error.localizedDescription)")
            }
        }
        
        return url
    }
}

