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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var fbSession: FBSession! {
        return FBSession.activeSession()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics(), Twitter()])
        
        Parse.setLogLevel(.Info)
        let config = ParseClientConfiguration(block: { (configuration) -> Void in
            
            configuration.applicationId = activeConfig.id
            configuration.clientKey = activeConfig.key
            configuration.server = activeConfig.url
        })
        
        Parse.initializeWithConfiguration(config)
        PFFacebookUtils.initializeFacebook()

        if application.applicationState != .Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        JSONLoader.sharedLoader.handleFirstRun()
        
        ParseHelper.sharedHelper.refresh { (result:RefreshCompletionAction) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.CloudRefreshDidFinish.rawValue, object: nil)
            }
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication, withSession: fbSession)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        FBAppEvents.activateApp()
        FBAppCall.handleDidBecomeActiveWithSession(fbSession)
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataHelper.sharedHelper.saveContext()
    }
}

