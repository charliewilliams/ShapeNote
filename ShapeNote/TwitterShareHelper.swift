//
//  TwitterShareHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 03/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import Social
import TwitterKit

class TwitterShareHelper: NSObject {
    
    var leading:Leading?
    
    class var sharedHelper : TwitterShareHelper {
        struct Static {
            static let instance : TwitterShareHelper = TwitterShareHelper()
        }
        return Static.instance
    }
    
    func postLeading(leading:Leading) {
        
        // WARNING: DEBUG
//        println("Not posting test run to Twitter")
//        return;
        
        self.leading = leading
        let statusPostEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
        let params = ["status": leading.twitterString()]
        
        // lat, long
        
        var clientError : NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("POST", URL: statusPostEndpoint, parameters: params, error: &clientError)
        
        if request != nil {
            
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {(response, data, connectionError) -> Void in
                
                if connectionError == nil {
                    var jsonError : NSError?
                    let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError)
                    
                    if jsonError != nil {
                        println("Error: \(jsonError)")
                    } else {
                        println(json)
                    }
                }
                else {
                    println("Error: \(connectionError)")
                }
            }
        }
        else {
            println("Error: \(clientError)")
        }
    }
}
