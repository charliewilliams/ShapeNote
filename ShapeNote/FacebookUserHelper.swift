//
//  FacebookUserHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 06/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

typealias Completion = ([NSDictionary] -> ())

class FacebookUserHelper {
    
    class var sharedHelper : FacebookUserHelper {
        struct Static {
            static let instance:FacebookUserHelper = FacebookUserHelper()
        }
        return Static.instance
    }
    
    var completion:Completion?
    var fbUser:FBGraphUser?
    
    func singerLoggedInToFacebook(user: FBGraphUser, permissions:[String]?, completion:Completion) {
        
        self.completion = completion
        self.fbUser = user
        
        // 1. Get user name / first_name / id etc and put it on the user here
        for singer:Singer in CoreDataHelper.sharedHelper.singers() {
            if (singer.name == user.name) {
                singer.facebook = user.objectID
                singer.shortName = user.first_name
                CoreDataHelper.sharedHelper.currentSinger = singer
            }
        }
        
        // 2. Log in OR create the user on the server if they don't exist
        PFFacebookUtils.logInWithPermissions(permissions) { [weak self] (pfUser:PFUser?, error:NSError?) -> Void in
            
            guard let pfUser = pfUser else {
                self?.signUpNewUser(user, permissions:permissions)
                return
            }
            if (pfUser.isNew) {
                print("WELCOME")
            } else {
                print("WELCOME BACK")
            }
            
            self?.getGroupsForUser(user)
        }
    }
    
    func signUpNewUser(fbUser: FBGraphUser, permissions:[String]?) {
        
        self.fbUser = fbUser
        
        let userObject = fbUser as! FBGraphObject
        let pfUser = PFUser()
        pfUser.username = userObject["email"] as? String
        pfUser["first_name"] = userObject["first_name"] as? String
        pfUser["last_name"] = userObject["last_name"] as? String
        pfUser["name"] = userObject["name"] as? String
        pfUser["gender"] = userObject["gender"] as? String
        pfUser["locale"] = userObject["locale"] as? String
        pfUser["id"] = userObject["id"] as? String
        pfUser["timezone"] = userObject["timezone"] as? Int
        pfUser["fbProfileURL"] = userObject["link"] as? String
        pfUser["verified"] = userObject["verified"] as? Bool
        
        pfUser.password = "\(fbUser.hash)"
        
        pfUser.signUpInBackgroundWithBlock { [weak self] (success:Bool, error:NSError?) -> Void in
            self?.linkUser(pfUser, permissions: permissions)
        }
    }
    
    func linkUser(pfUser: PFUser, permissions:[String]?) {
        
        PFFacebookUtils.linkUser(pfUser, permissions: permissions) { [weak self] (success:Bool, error:NSError?) -> Void in
            print(error)
            
            if let fbUser = self?.fbUser
                where success && error == nil {
                self?.getGroupsForUser(fbUser)
            } else {
                self?.handleError(error)
            }
        }
    }
    
    func getGroupsForUser(user: FBGraphUser) {
        
        // 3. Get the list of groups and pick the ones that say "Sacred Harp"
        FBRequest(forGraphPath: "/\(user.objectID)/groups").startWithCompletionHandler { [weak self] (connection:FBRequestConnection!, data:AnyObject!, error:NSError!) -> Void in
            
            guard let data = data as? FBGraphObject,
                let groups = data["data"] as? [NSDictionary]
                where error == nil
                else { self?.handleError(error); return }
            
            if let user = PFUser.currentUser() {
                user["groups"] = groups
            }
            // 4. Return those so a view can make a "home singing" picker
            self?.completion?(groups)
        }
    }
    
    func handleError(error:NSError?) {
        
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
