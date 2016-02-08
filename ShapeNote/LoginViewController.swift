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

typealias ParseCompletionBlock = (user:PFUser?, error:NSError?) -> ()

extension UIViewController {
    var isModal: Bool {
        return presentingViewController?.presentedViewController == self
            || (navigationController != nil && navigationController?.presentingViewController?.presentedViewController == navigationController)
            || tabBarController?.presentingViewController is UITabBarController
    }
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var twitterLoginButton: TWTRLogInButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userFullNameLabel: UILabel!
    @IBOutlet var userInfoVerticalConstraint: NSLayoutConstraint!
    @IBOutlet var loginBenefitsView: UIView!
    @IBOutlet weak var facebookLoginSpinner: UIActivityIndicatorView!
    
    var session: TWTRSession?
    var showingGroupsPicker = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            self?.checkFacebookLoginStatus()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(!isModal, animated: true)
        
        // If we have a local user with info, set that before hitting the network!
        checkFacebookLoginStatus()
        
        if let twSession = Twitter.sharedInstance().sessionStore.session() {
            fixTwitterLoginStateForSession(twSession)
        }
    }

    // MARK: ----------- Facebook functions
    
    @IBAction func facebookLoginButtonPressed(sender: UIButton) {
        
        if PFUser.currentUser() == nil {
            
            facebookLoginButton.setTitle("", forState: .Normal)
            facebookLoginSpinner.startAnimating()
            SwiftSpinner.show("Logging in")
            FacebookUserHelper.sharedHelper.loginWithCompletion { [weak self] (user:PFUser?, error:NSError?) in
                SwiftSpinner.hide()
                self?.facebookLoginSpinner.stopAnimating()
                if let user = user where error == nil {
                    self?.showLoggedInUser(user)
                    if self?.shouldShowGroupsPicker() == true {
                        self?.showGroupsPicker()
                    }
                } else {
                    self?.handleError(error)
                }
            }
            TabBarManager.sharedManager.clearLoginTab()
            
        } else {
            
            FacebookUserHelper.sharedHelper.logOut()
            showLoggedOutUser()
        }
    }
    

    
    func checkFacebookLoginStatus() {
        
        if let user = PFUser.currentUser() {
            
            showLoggedInUser(user)
            
        } else {
            
            showLoggedOutUser()
            
        }
    }
    
    func showLoggedInUser(user: PFUser) {
        userFullNameLabel.text = "Logged in as \(user[PFKeys.name.rawValue]!)"
        userFullNameLabel.font = UIFont.boldSystemFontOfSize(loggedInPointSize)
        facebookLoginButton.setTitle("Log out", forState: .Normal)
        setConstraintsForFacebookLoginStatus(true)
    }
    
    func showLoggedOutUser() {
        userFullNameLabel.text = "Log in to find your local singing"
        userFullNameLabel.font = UIFont.boldSystemFontOfSize(loggedOutPointSize)
        facebookLoginButton.setTitle("Log in with Facebook", forState: .Normal)
        setConstraintsForFacebookLoginStatus(false)
    }
    
    func setConstraintsForFacebookLoginStatus(loggedIn: Bool) {
        
        twitterLoginButton.hidden = !loggedIn
        
        if loggedIn == true {
            Defaults.neverLoggedIn = false
            TabBarManager.sharedManager.clearLoginTab()
            userInfoVerticalConstraint.constant = loggedInVerticalConstant
            loginBenefitsView.alpha = 0
        } else {
            userInfoVerticalConstraint.constant = loggedOutVerticalConstant
            loginBenefitsView.alpha = 1
        }
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
