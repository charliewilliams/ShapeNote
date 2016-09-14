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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        window?.backgroundColor = UIColor(patternImage: UIImage(named: "Launch")!)
        
        Fabric.with([Crashlytics(), Twitter()])
        
        JSONLoader.sharedLoader.handleFirstRun()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataHelper.sharedHelper.saveContext()
    }
}

