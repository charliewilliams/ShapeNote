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
            print(permissions)
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
                print(error)
            }
            
            if session != nil {
                self.session = session
                self.fixTwitterLoginStateForSession(session!)
            }
        }
    }
    
    class func doFacebookLogin() {
        
        let session = FBSession.activeSession()
        
        if session.isOpen == false {
            
            session.openWithBehavior(FBSessionLoginBehavior.UseSystemAccountIfPresent, completionHandler: { (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
                self.refreshPublishPermissions(session)
            });
            
        } else {
            
            refreshPublishPermissions(session)
        }
    }
    
    class func refreshPublishPermissions(session:FBSession!) {
        
        let writePermissions = ["public_profile", "user_friends", "email", "user_groups", "publish_actions"]
        session.requestNewPublishPermissions(writePermissions, defaultAudience: .Everyone) { (session:FBSession!, publishError:NSError!) -> Void in
            
            if publishError != nil {
                print(publishError)
            }
        }
    }
    
    // Facebook functions
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        print("Facebook login error: \(error)")
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        print(loginView)
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        print(loginView)        
    }
    
    func fixTwitterLoginStateForSession(session:TWTRSession) {
        
        for view in twitterLoginButton.subviews {
            
            if let label = view as? UILabel {
                
                setTwitterText("Logged in as @\(session.userName)", onLabel: label)
                
            } else {
                    
                for vview in view.subviews {
                    
                    if let label = vview as? UILabel {
                        
                        setTwitterText("Logged in as @\(session.userName)", onLabel: label)
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
