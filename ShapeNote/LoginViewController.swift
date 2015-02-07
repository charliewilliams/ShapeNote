//
//  LoginViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet weak var twitterLoginButton: TWTRLogInButton!
    @IBOutlet weak var facebookLoginButton: FBLoginView!
    var loggingIn:Bool = false
    var session: TWTRSession?
    
    // Twitter functions
    @IBAction func twitterLoginButtonPressed(sender: TWTRLogInButton) {
        
        twitterLoginButton.logInCompletion = {(session:TWTRSession!, error:NSError!) -> Void in
            
            if error != nil {
                println(error)
            }
            
            if session != nil {
                self.session = session
                self.twitterLoginButton.setTitle("Logged in as \(session.userName)", forState: .Normal)
            }
        }
    }
    
    
    // Facebook functions
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        println(user)
        
        let permissions = ["public_profile", "user_friends", "email"]
        
        PFFacebookUtils.logInWithPermissions(permissions, { (pfUser:PFUser!, error:NSError!) -> Void in
            
            if pfUser == nil {
                println("Error - user cancelled")
                return
            }
            
            FBSession.openActiveSessionWithPublishPermissions(["publish_actions"], defaultAudience: FBSessionDefaultAudience.Friends, allowLoginUI: true, completionHandler: { (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
                
            })
            
            FBRequest.requestForMe()?.startWithCompletionHandler({ (connection:FBRequestConnection!, info:AnyObject!, error:NSError!) -> Void in
                
                println(info)
            })
            
//            PFFacebookUtils.reauthorizeUser(pfUser, withPublishPermissions:["publish_actions" as AnyObject], audience:FBSessionDefaultAudience.Friends, { (succeeded: Bool!, error: NSError!) -> Void in
//                if succeeded == true {
//                    // Your app now has publishing permissions for the user
//                }
//            })
        })
        

    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        println("Facebook login error: \(error)")
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {

    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        
    }
}
