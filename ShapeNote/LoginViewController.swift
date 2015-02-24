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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let twSession = Twitter.sharedInstance().session() {
            
            fixTwitterLoginStateForSession(twSession)
        }
        
        if let fbSession = FBSession.activeSession() {
            
            let permissions = fbSession.permissions as NSArray
            println(permissions)
            if permissions.containsObject("publish_actions") == false || permissions.containsObject("user_groups") == false {
                LoginViewController.doFacebookLogin()
            }
        } else {
            LoginViewController.doFacebookLogin()
        }
    }

    // Twitter functions
    @IBAction func twitterLoginButtonPressed(sender: TWTRLogInButton) {
        
        twitterLoginButton.logInCompletion = {(session:TWTRSession!, error:NSError!) -> Void in
            
            if error != nil {
                println(error)
            }
            
            if session != nil {
                self.session = session
                self.fixTwitterLoginStateForSession(session!)
            }
        }
    }
    
    class func doFacebookLogin() {
        
        let writePermissions = ["public_profile", "user_friends", "email", "user_groups", "publish_actions"]
        let session = FBSession.activeSession()
        
        FBSession.activeSession().requestNewPublishPermissions(writePermissions, defaultAudience: .Everyone) { (session:FBSession!, publishError:NSError!) -> Void in
            
            if publishError != nil {
                println(publishError)
            }
        }
    }
    
    // Facebook functions
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
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
    
    func fixTwitterLoginStateForSession(session:TWTRSession) {
        
        if let subviews = twitterLoginButton.subviews as? [UIView] {
            
            for view in subviews {
                
                if let label = view as? UILabel {
                    
                    setTwitterText("Logged in as @\(session.userName)", onLabel: label)
                    
                } else if let subsub = view.subviews as? [UIView] {
                    
                    for vview in subsub {
                        
                        if let label = vview as? UILabel {
                            
                            setTwitterText("Logged in as @\(session.userName)", onLabel: label)
                        }
                    }
                }
            }
        }
    }
    
    func setTwitterText(string:String, onLabel label:UILabel) {
        
        label.text = string
        label.setNeedsLayout()
        twitterLoginButton.setNeedsLayout()
    }
    
}
