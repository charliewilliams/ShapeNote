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
                
//                let user = PFUser.currentUser()
//                user.setObject("@" + session.userName, forKey: "twitterUserName")
//                user.setObject(session.authToken, forKey: "twitterSessionAuthToken")
//                user.setObject(session.authTokenSecret, forKey: "twitterSessionAuthSecret")
            }
        }
    }
    
    func doFacebookLogin() {
        
        let permissions = ["public_profile", "user_friends", "email"]
        
//        let user = PFUser.currentUser()
        
//        PFFacebookUtils.linkUser(user, permissions: permissions) { (success:Bool, error:NSError!) -> Void in
//            
//            PFUser.becomeInBackground(user.sessionToken, block: { (user:PFUser!, becomeError:NSError!) -> Void in
//                
//                if becomeError != nil {
//                    println(becomeError)
//                }
//            })
        
            FBSession.openActiveSessionWithPublishPermissions(["publish_actions"], defaultAudience: FBSessionDefaultAudience.Friends, allowLoginUI: true, completionHandler: { (session:FBSession!, state:FBSessionState, publishError:NSError!) -> Void in
                
                if publishError != nil {
                    println(publishError)
                }
            })
            
            FBRequest.requestForMe()?.startWithCompletionHandler({ (connection:FBRequestConnection!, info:AnyObject!, infoError:NSError!) -> Void in
                
                if infoError != nil {
                    println(infoError)
                }
                println(info)
            })
//        }
    }
    
    // Facebook functions
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        println(user)
        if user != nil { //&& PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) == true {
            
            doFacebookLogin()
        }
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        println("Facebook login error: \(error)")
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println(loginView)
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println(loginView)        
    }
}
