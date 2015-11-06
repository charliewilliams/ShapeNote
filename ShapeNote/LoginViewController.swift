//
//  LoginViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import Twitter
import TwitterKit

let loggedOutVerticalConstant:CGFloat = 10
let loggedInVerticalConstant:CGFloat = 90

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet weak var twitterLoginButton: TWTRLogInButton!
    @IBOutlet weak var facebookLoginButton: FBLoginView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userFullNameLabel: UILabel!
    @IBOutlet var userInfoVerticalConstraint: NSLayoutConstraint!
    
    var loggingIn:Bool = false
    var session: TWTRSession?
    var facebookUser: FBGraphUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.facebookLoginButton.readPermissions = requiredFacebookReadPermissions()
        self.facebookLoginButton.publishPermissions = requiredFacebookWritePermissions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // If we have a local user with info, set that before hitting the network!
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            self?.checkFacebookLoginStatus()
        }
        
        if let twSession = Twitter.sharedInstance().sessionStore.session() {
            fixTwitterLoginStateForSession(twSession)
        }
        
        checkFacebookLoginStatus()
    }
    
    // MARK: ----------- Facebook functions
    func requiredFacebookReadPermissions() -> [String] {
        return ["public_profile", "user_friends", "email", "user_groups"]
    }
    
    func requiredFacebookWritePermissions() -> [String] {
        return ["publish_actions"]
    }
    
    func allRequiredFacebookPermissions() -> [String] {
        return requiredFacebookReadPermissions() + requiredFacebookWritePermissions()
    }
    
    func checkFacebookLoginStatus() {
        
        if let fbSession = FBSession.activeSession()
            where fbSession.isOpen {
                
                setConstraintsForFacebookLoginStatus(true)
                
                let permissions = fbSession.permissions as NSArray
                print(permissions)
                if permissions.containsObject("publish_actions") == false || permissions.containsObject("user_groups") == false {
                    doManualFacebookLogin()
                }
        } else {
            setConstraintsForFacebookLoginStatus(false)
        }
    }
    
    func doManualFacebookLogin() {
        
        let session = FBSession.activeSession()
        
        if session.isOpen == true {
            
            refreshPublishPermissions(session)
            
        } else {
            
            session.openWithBehavior(.UseSystemAccountIfPresent, fromViewController: self, completionHandler: { [weak self] (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
                    if let self_ = self {
                        self_.refreshPublishPermissions(session);
                    }
                })
        }
    }
    
    func setConstraintsForFacebookLoginStatus(loggedIn: Bool) {
        
        twitterLoginButton.hidden = !loggedIn
        
        if loggedIn == true {
            userInfoVerticalConstraint.constant = loggedInVerticalConstant
        } else {
            userInfoVerticalConstraint.constant = loggedOutVerticalConstant
        }
    }
    
    func refreshPublishPermissions(session:FBSession!) {
        
        let permissions = session.permissions as! [String]
        let missingPermissions = allRequiredFacebookPermissions().filter { (element:String) -> Bool in
            return !permissions.contains(element)
        }
        
        if missingPermissions.count == 0 { return }
        
        session.requestNewPublishPermissions(missingPermissions, defaultAudience: .Everyone) { [weak self] (session:FBSession!, publishError:NSError!) -> Void in
            
            if publishError != nil {
                print(publishError)
            } else if let user = self?.facebookUser {
                
                guard let permissions = session.permissions as? [String] else { fatalError("Got weird response from server") }
                
                FacebookUserHelper.sharedHelper.singerLoggedInToFacebook(user, permissions: permissions) { [weak self] (groups:[NSDictionary]) in
                    if self?.shouldShowGroupsPicker() == true {
                        self?.showGroupsPicker(groups)
                    }
                }
            }
        }
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        facebookUser = user
        self.userFullNameLabel.text = user.name
        
        // TODO only if we need to download the photo!
//        FBRequest.requestForMe().startWithCompletionHandler { (connection:FBRequestConnection!, data:AnyObject!, error:NSError!) -> Void in
//            
//            print(data)
//        }
        
        guard let permissions = FBSession.activeSession().permissions as? [String] else { return }
        
        FacebookUserHelper.sharedHelper.singerLoggedInToFacebook(user, permissions: permissions) { [weak self] (groups:[NSDictionary]) -> () in
            if self?.shouldShowGroupsPicker() == true {
                self?.showGroupsPicker(groups)
            }
        }
    }
    
    func shouldShowGroupsPicker() -> Bool {
        // Check to see if we don't have a group?
        return true
    }
    
    func showGroupsPicker(groups:[NSDictionary]) {
        let pickerVC = GroupsPickerViewController(nibName:"GroupsPickerViewController", bundle: nil)
        pickerVC.groups = groups
        self.presentViewController(pickerVC, animated: true, completion: nil)
//        self.showViewController(pickerVC, sender: nil)
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        print("Facebook login error: \(error)")
    }
    
    // MARK: ----------- Twitter functions
    @IBAction func twitterLoginButtonPressed(sender: TWTRLogInButton) {
        
        twitterLoginButton.logInCompletion = {(session:TWTRSession?, error:NSError?) -> Void in
            
            if error != nil {
                print(error)
            }
            
            if session != nil {
                self.session = session
                self.fixTwitterLoginStateForSession(session!)
            }
        }
    }
    
    func fixTwitterLoginStateForSession(session:TWTRAuthSession) {
        
        for view in twitterLoginButton.subviews {
            
            if let label = view as? UILabel {
                
                setTwitterText("Logged in as @\(session.userID)", onLabel: label)
                
            } else {
                
                for vview in view.subviews {
                    
                    if let label = vview as? UILabel {
                        
                        setTwitterText("Logged in as @\(session.userID)", onLabel: label)
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
