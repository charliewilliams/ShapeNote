//
//  FacebookShareHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 12/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

let groupGraphString = "/159750340866331/feed"

class FacebookShareHelper: NSObject {
    
    class func canPostToFacebook() -> Bool {
        
        let permissions:NSArray = FBSession.activeSession().permissions
        return permissions.containsObject("publish_actions")
    }
    
    class func postMinutesToFacebook(minutes:Minutes) {
        
        let params = ["message": minutes.stringForSocialMedia()]

        FBRequestConnection.startWithGraphPath(groupGraphString, parameters: params, HTTPMethod: "POST") { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            
            if error != nil {
                
                print("error \(error) posting minutes")
                // TODO handle error in UI
                
            } else {
                
                print("posted minutes: \(result)")
            }
        }
    }
}
