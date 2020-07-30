//
//  AppDelegate.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

let backgroundImage = UIImage(named: "Launch")!
let backgroundImageColor = UIColor(patternImage:backgroundImage)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        window?.backgroundColor = backgroundImageColor
    
        JSONLoader.sharedLoader.handleFirstRun()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataHelper.sharedHelper.saveContext()
    }
}

