//
//  FacebookShareHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 12/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

let groupGraphString = "/bristolsacredharp/feed"
class FacebookShareHelper: NSObject {
    
    class func postMinutesToFacebook(minutes:Minutes?) {
        
        let params = ["message":"test"] //minutes.stringForSocialMedia()]
        
        FBRequestConnection.startWithGraphPath(groupGraphString, parameters: params, HTTPMethod: "POST") { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            
            if error != nil {
                
                println("error \(error) posting minutes")
                
            } else {
                
                println("posted minutes: \(result)")
            }
        }
    }
}
