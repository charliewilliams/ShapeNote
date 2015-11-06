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
    
    func singerLoggedInToFacebook(user: FBGraphUser, permissions:[String]?, completion:Completion) {
        
        self.completion = completion
        
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
    
    func signUpNewUser(user: FBGraphUser, permissions:[String]?) {
        
        let pfUser = PFUser()
        
        if PFFacebookUtils.isLinkedWithUser(pfUser) {
            return
        }
        
        PFFacebookUtils.linkUser(pfUser, permissions: permissions) { [weak self] (success:Bool, error:NSError?) -> Void in
            print(error)
            
            if success && error == nil {
                self?.getGroupsForUser(user)
            }
        }
    }
    
    func getGroupsForUser(user: FBGraphUser) {
        
        // 3. Get the list of groups and pick the ones that say "Sacred Harp"
        FBRequest(forGraphPath: "/\(user.objectID)/groups").startWithCompletionHandler { [weak self] (connection:FBRequestConnection!, data:AnyObject!, error:NSError!) -> Void in
            
            guard let data = data as? FBGraphObject,
                let groups = data["data"] as? [NSDictionary]
                where error == nil
                else { self?.handleError(); return }
            
            // 4. Return those so a view can make a "home singing" picker
            self?.completion?(groups)
        }

    }
    
    func handleError() {
        
        
    }
}
