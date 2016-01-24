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
import SwiftSpinner

let loggedOutVerticalConstant:CGFloat = 10
let loggedInVerticalConstant:CGFloat = -62
let loggedInPointSize:CGFloat = 14
let loggedOutPointSize:CGFloat = 17
let userCanceled = 2

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet weak var twitterLoginButton: TWTRLogInButton!
    @IBOutlet weak var facebookLoginButton: FBLoginView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userFullNameLabel: UILabel!
    @IBOutlet var userInfoVerticalConstraint: NSLayoutConstraint!
    @IBOutlet var loginBenefitsView: UIView!
    
    var session: TWTRSession?
    var facebookUser: FBGraphUser?
    var showingGroupsPicker = false
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.facebookLoginButton.readPermissions = requiredFacebookReadPermissions()
        self.facebookLoginButton.publishPermissions = requiredFacebookWritePermissions()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            self?.checkFacebookLoginStatus()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(!isModal, animated: true)
        
        // If we have a local user with info, set that before hitting the network!
        checkFacebookLoginStatus()
        
        if let twSession = Twitter.sharedInstance().sessionStore.session() {
            fixTwitterLoginStateForSession(twSession)
        }
    }

    // MARK: ----------- Facebook functions
    func requiredFacebookReadPermissions() -> [String] {
        return ["public_profile", "user_friends", "email", "user_likes", "user_managed_groups", "user_groups"]
    }
    
    func requiredFacebookWritePermissions() -> [String] {
        return ["publish_actions", "publish_pages", "manage_pages"]
    }
    
    func allRequiredFacebookPermissions() -> [String] {
        return requiredFacebookReadPermissions() + requiredFacebookWritePermissions()
    }
    
    func checkFacebookLoginStatus() {
        
        if let fbSession = FBSession.activeSession()
            where fbSession.isOpen {
                
                setConstraintsForFacebookLoginStatus(true)

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
            loginBenefitsView.alpha = 0
        } else {
            userInfoVerticalConstraint.constant = loggedOutVerticalConstant
            loginBenefitsView.alpha = 1
        }
    }
    
    func refreshPublishPermissions(session:FBSession!) {
        
        let permissions = session.permissions as? [String] ?? [String]()
        let missingPermissions = allRequiredFacebookPermissions().filter { (element:String) -> Bool in
            return !permissions.contains(element)
        }
        
        if missingPermissions.count == 0 { return }
        
//        session.reauthorizeWithPublishPermissions(requiredFacebookWritePermissions(), defaultAudience: .Everyone) { [weak self] (session:FBSession!, publishError:NSError!) -> Void in
//            if publishError != nil {
//                print(publishError)
//            } else if let user = self?.facebookUser {
//                
//                guard let permissions = session.permissions as? [String] else { fatalError("Got weird response from server") }
//                
//                FacebookUserHelper.sharedHelper.singerLoggedInToFacebook(user, permissions: permissions) { [weak self] () in
//                    self?.showLoggedInUserName(user)
//                    if self?.shouldShowGroupsPicker() == true {
//                        self?.showGroupsPicker()
//                    }
//                }
//            }
//        }
        
        session.requestNewPublishPermissions(allRequiredFacebookPermissions(), defaultAudience: .Everyone) { [weak self] (session:FBSession!, publishError:NSError!) -> Void in
            
            if publishError != nil {
                self?.handleError(publishError)
            } else if let user = self?.facebookUser {
                
                guard let permissions = session.permissions as? [String] else { fatalError("Got weird response from server") }
                
                FacebookUserHelper.sharedHelper.singerLoggedInToFacebook(user, permissions: permissions) { [weak self] (result:RefreshCompletionAction) in
                    self?.showLoggedInUserName(user)
                    if self?.shouldShowGroupsPicker() == true {
                        self?.showGroupsPicker()
                    }
                }
            }
        }
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        TabBarManager.sharedManager.clearLoginTab()
        Defaults.neverLoggedIn = false
        
        facebookUser = user
        showLoggedInUserName(user)
        
        guard let session = FBSession.activeSession() where session.isOpen && session.state != .CreatedOpening else {
            doManualFacebookLogin();
            return
        }
        
        guard let permissions = session.permissions as? [String] else {
            refreshPublishPermissions(session)
            return
        }
        
        SwiftSpinner.show("Logging into Facebook", animated: true)
        FacebookUserHelper.sharedHelper.singerLoggedInToFacebook(user, permissions: permissions) { [weak self] (result:RefreshCompletionAction) in
            
            SwiftSpinner.hide()
            if self?.shouldShowGroupsPicker() == true {
                self?.showGroupsPicker()
            }
        }
    }
    
    func showLoggedInUserName(user: FBGraphUser) {
        self.userFullNameLabel.text = "Logged in as \(user.name)"
        self.userFullNameLabel.font = UIFont.boldSystemFontOfSize(loggedInPointSize)
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        
        if let user = facebookUser {
            showLoggedInUserName(user)
        }
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        userFullNameLabel.text = "Log in to find your local singing"
        userFullNameLabel.font = UIFont.boldSystemFontOfSize(loggedOutPointSize)
        setConstraintsForFacebookLoginStatus(false)
    }
    
    func shouldShowGroupsPicker() -> Bool {
        guard let user = PFUser.currentUser(),
            let singer = user[PFKey.singer.rawValue] as? PFObject else { return false }
        
        do {
            try singer.fetchIfNeeded()
        } catch let error as NSError {
            handleError(error)
            return false
        }
        
        if singer[PFKey.group.rawValue] == nil
            && CoreDataHelper.sharedHelper.groups().count > 0
            && showingGroupsPicker == false {
                showingGroupsPicker = true
                return true
        }
        return false
    }
    
    func showGroupsPicker() {
        let pickerVC = GroupsPickerViewController(nibName:"GroupsPickerViewController", bundle: nil)
        self.presentViewController(pickerVC, animated: true, completion: nil)
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        
        SwiftSpinner.hide()
        if error.code != userCanceled {
            handleError(error)
        }
        print("Facebook login error: \(error)")
    }
    
    // MARK: ----------- Twitter functions
    @IBAction func twitterLoginButtonPressed(sender: TWTRLogInButton) {

        SwiftSpinner.show("Logging into Twitter", animated: true)
        twitterLoginButton.logInCompletion = { [weak self] (session:TWTRSession?, error:NSError?) -> Void in
            
            SwiftSpinner.hide()
            if error != nil {
                self?.handleError(error)
            }
            
            if session != nil {
                self?.session = session
                self?.fixTwitterLoginStateForSession(session!)
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
    
    func handleError(error:NSError?) {
        
        var message = "There was an error talking to Facebook. That's all we know."
        if let error = error
            where error.localizedDescription.characters.count > 4 {
                message = error.localizedDescription
        }
        let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
