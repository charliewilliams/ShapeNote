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
    
    var lesson: Lesson?
    
    class var sharedHelper: TwitterShareHelper {
        struct Static {
            static let instance: TwitterShareHelper = TwitterShareHelper()
        }
        return Static.instance
    }
    
    func postLesson(_ lesson:Lesson) {
        
        // WARNING: DEBUG
        #if DEBUG
        print("Not posting test run to Twitter: \(lesson.twitterString())")
        return;
        #endif

        self.lesson = lesson
        let statusPostEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
        let params = ["status": lesson.twitterString()]
        
        guard let userId = Twitter.sharedInstance().sessionStore.session()?.userID else {
            return
        }
        
        let client = TWTRAPIClient(userID: userId)
        var clientError : NSError? = nil
        let request: URLRequest! = client.urlRequest(withMethod: "POST", url: statusPostEndpoint, parameters: params, error: &clientError)
        if let error = clientError {
            print("Error connecting to Twitter: " + error.localizedDescription)
        }
        
        guard request != nil else {
            print("Error: \(clientError)")
            return
        }
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            
            if let data = data, connectionError == nil {
                var jsonError : NSError?
                let json : Any?
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: [])
                } catch let error as NSError {
                    jsonError = error
                    json = nil
                } catch {
                    fatalError()
                }
                
                if jsonError != nil {
                    print("Error: \(jsonError)")
                } else {
                    print("\(json)")
                }
            }
            else {
                print("Error: \(connectionError)")
            }
        }
    }
}
