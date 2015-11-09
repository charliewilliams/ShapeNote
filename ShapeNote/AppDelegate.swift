//
//  AppDelegate.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit
import ParseFacebookUtils
//import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics(), Twitter()])
        
        Parse.setApplicationId("MvJxV7TztlSI8c0bi59MR6HqUfe24N53Rhgsa51a", clientKey: "2exXKyLLRXMe2WM8maCDEOVB2yTrRm6i5cLTUOP6")
        PFFacebookUtils.initializeFacebook()
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        JSONLoader.sharedLoader.handleFirstRun()
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
//        let session = PFFacebookUtils.session()
        let session = FBSession.activeSession()
        
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication, withSession: session)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBAppEvents.activateApp()
        
//        let session = PFFacebookUtils.session()
        let session = FBSession.activeSession()
        FBAppCall.handleDidBecomeActiveWithSession(session)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataHelper.sharedHelper.saveContext()
    }



}

