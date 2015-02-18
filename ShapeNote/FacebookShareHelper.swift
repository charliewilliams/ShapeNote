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
    
    class func postMinutesToFacebook(minutes:Minutes?) {
        
        let params = ["message":"test"] //minutes.stringForSocialMedia()]
        let permissions:NSArray = FBSession.activeSession().permissions
        
        if permissions.containsObject("publish_actions") == false {
//             permission does not exist
            
            println("Don't have permissions: \(permissions)")
        }
        
        FBRequestConnection.startWithGraphPath(groupGraphString, parameters: params, HTTPMethod: "POST") { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            
            println(error)
            if error != nil {
                
                println("error \(error) posting minutes")
                
            } else {
                
                println("posted minutes: \(result)")
            }
        }
    }
}
