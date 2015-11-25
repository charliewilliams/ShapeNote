//
//  FacebookUserHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 06/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation
import ParseFacebookUtils

typealias Completion = (() -> ())

class FacebookUserHelper {
    
    class var sharedHelper : FacebookUserHelper {
        struct Static {
            static let instance:FacebookUserHelper = FacebookUserHelper()
        }
        return Static.instance
    }

    var fbUser:FBGraphUser?
    
    func singerLoggedInToFacebook(user: FBGraphUser, permissions:[String]?, completion:RefreshCompletionBlock) {
        
        self.fbUser = user
        
        // 1. Get user name / first_name / id etc and put it on the user here
        for singer:Singer in CoreDataHelper.sharedHelper.singers() {
            if (singer.name == user.name) {
                singer.facebook = user.objectID
                singer.firstName = user.first_name
                CoreDataHelper.sharedHelper.currentSinger = singer
            }
        }
        
        // ???
        if let _ = PFUser.currentUser() {
            ParseHelper.sharedHelper.refresh({ (result:RefreshCompletionAction) in
                completion(result)
            })
            return
        }
        
        // 2. Log in OR create the user on the server if they don't exist
        PFFacebookUtils.logInWithPermissions(permissions) { (pfUser:PFUser?, error:NSError?) in
            
            guard let pfUser = pfUser else {
                self.signUpNewUser(user, permissions:permissions)
                return
            }
            if (pfUser.isNew) {
                print("WELCOME")
            } else {
                print("WELCOME BACK")
            }
        
            let user = user as! FBGraphObject
            self.copyDataFromFacebookUser(user, toParseUser: pfUser)
            
            ParseHelper.sharedHelper.refresh({ (result:RefreshCompletionAction) in
                completion(result)
            })
        }
    }
    
    func signUpNewUser(fbUser: FBGraphUser, permissions:[String]?) {
        
        self.fbUser = fbUser
        
        let userObject = fbUser as! FBGraphObject
        let pfUser = PFUser()
        copyDataFromFacebookUser(userObject, toParseUser:pfUser)
        
        pfUser.signUpInBackgroundWithBlock { [weak self] (success:Bool, error:NSError?) -> Void in
            self?.linkUser(pfUser, permissions: permissions)
        }
    }
    
    func copyDataFromFacebookUser(facebookUser:FBGraphObject, toParseUser pfUser:PFUser) {
        
        pfUser.username = facebookUser["email"] as? String
        pfUser["first_name"] = facebookUser["first_name"] as? String
        pfUser["last_name"] = facebookUser["last_name"] as? String
        pfUser["name"] = facebookUser["name"] as? String
        pfUser["gender"] = facebookUser["gender"] as? String
        pfUser["locale"] = facebookUser["locale"] as? String
        pfUser["id"] = facebookUser["id"] as? String
        pfUser["timezone"] = facebookUser["timezone"] as? Int
        pfUser["fbProfileURL"] = facebookUser["link"] as? String
        pfUser["verified"] = facebookUser["verified"] as? Bool
    }
    
    func linkUser(pfUser: PFUser, permissions:[String]?) {
        
        PFFacebookUtils.linkUser(pfUser, permissions: permissions) { [weak self] (success:Bool, error:NSError?) in
            print(error)
            
            if let _ = self?.fbUser
                where success && error == nil {
                    
                    ParseHelper.sharedHelper.refresh({ (result:RefreshCompletionAction) in
                        
                    })
                    
                // just awesome I guess
                    
            } else {
                self?.handleError(error)
            }
        }
    }
    
//    func getGroupsForUser(user: FBGraphUser) {
//        
//        // 3. Get the list of groups and pick the ones that say "Sacred Harp"
//        FBRequest(forGraphPath: "/\(user.objectID)/groups").startWithCompletionHandler { [weak self] (connection:FBRequestConnection!, data:AnyObject!, error:NSError!) -> Void in
//            
//            guard let data = data as? FBGraphObject,
//                let groups = data["data"] as? [NSDictionary]
//                where error == nil
//                else { self?.handleError(error); return }
//            
//            if let user = PFUser.currentUser() where groups.count > 0 {
//                user["groups"] = groups
//            }
//            // 4. Return those so a view can make a "home singing" picker
//            self?.completion?(groups)
//        }
//    }
    
    func handleError(error:NSError?) {
        
        // Todo detect if offline
        var message = "There was an error talking to the cloud. That's all we know."
        if let error = error
            where error.localizedDescription.characters.count > 4 {
                message = error.localizedDescription
        }
        let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
}
