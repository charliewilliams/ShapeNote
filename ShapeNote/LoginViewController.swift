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
        
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        
    }
}
