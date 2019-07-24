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

typealias TwitterLoginCompletion = (String?) -> ()

enum TwitterLoginState {
    case loggedOut
    case started
    case loggedIn
}

struct TwitterShareHelper {
    
    static let instance = TwitterShareHelper()
    static var state: TwitterLoginState = .loggedOut
    static var completions = [TwitterLoginCompletion]()
    static var session: TWTRSession?
    
    private init() {
        
        if TwitterShareHelper.session == nil,
            let twitterId = Defaults.twitterId,
            let s = Twitter.sharedInstance().sessionStore.session(forUserID: twitterId) as? TWTRSession {
            TwitterShareHelper.session = s
        }
    }
    
    static func setUpTwitter(completion: @escaping TwitterLoginCompletion) {
        
        guard Defaults.hasTwitter else {
            completion(nil)
            return
        }
        
        if let session = session {
            completion(session.userName)
            return
        }
        
        completions.append(completion)
        
        if state == .started {
            return
        }
        state = .started
        
        if let twitterID = Defaults.twitterId,
            let session = Twitter.sharedInstance().sessionStore.session(forUserID: twitterID) as? TWTRSession {
            finishSetup(withSession: session)
        }
        else if Defaults.hasTwitter {
            logIntoTwitter()
        } else {
            finishSetup(withSession: nil)
        }
    }
    
    static func logIntoTwitter() {
        
        Twitter.sharedInstance().logIn { (session: TWTRSession?, error: Error?) in
            self.finishSetup(withSession: session)
        }
    }
    
    static func logOut() {
        
        finishSetup(withSession: nil)
    }
    
    static private func finishSetup(withSession session: TWTRSession?) {
        
        if Defaults.hasTwitter, let session = session {
            
            Defaults.hasTwitter = true
            Defaults.twitterId = session.userID
            
            self.session = session
            state = .loggedIn
            
        } else {
            
            Defaults.hasTwitter = false
            state = .loggedOut
        }
        
        for completion in completions {
            completion(session?.userName)
        }
        completions.removeAll()
    }
}

extension TwitterShareHelper {

    static func postLesson(_ lesson:Lesson) {
        
        // WARNING: DEBUG
//        #if DEBUG
//        print("Not posting test run to Twitter: \(lesson.twitterString())")
//        return
//        #endif

        let statusPostEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
        let params = ["status": lesson.twitterString()]
        
        guard Defaults.hasTwitter, let session = session else {
            print("No twitter user Id available")
            return
        }
        
        let userId = session.userID
        
        let client = TWTRAPIClient(userID: userId)
        var clientError : NSError? = nil
        let request = client.urlRequest(withMethod: "POST", urlString: statusPostEndpoint, parameters: params, error: &clientError)
        if let error = clientError {
            print("Error connecting to Twitter for user \(userId): \(error.localizedDescription)")
        }
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            
            // All of this is just response handling, which we don't do anything with
            guard let data = data, connectionError == nil else {
                print("Error: \(String(describing: connectionError))")
                return
            }
            
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
                print("Error: \(String(describing: jsonError))")
            } else {
                print("\(String(describing: json))")
            }
        }
    }
}
