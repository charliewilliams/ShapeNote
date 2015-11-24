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
import Instructions

let loggedOutVerticalConstant:CGFloat = 10
let loggedInVerticalConstant:CGFloat = -62
let loggedInPointSize:CGFloat = 14
let loggedOutPointSize:CGFloat = 17
let userCanceled = 2

class LoginViewController: UIViewController, FBLoginViewDelegate, CoachMarksControllerDataSource {
    
    @IBOutlet weak var twitterLoginButton: TWTRLogInButton!
    @IBOutlet weak var facebookLoginButton: FBLoginView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userFullNameLabel: UILabel!
    @IBOutlet var userInfoVerticalConstraint: NSLayoutConstraint!
    
    var loggingIn:Bool = false
    var session: TWTRSession?
    var facebookUser: FBGraphUser?
    var coachMarksController: CoachMarksController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.facebookLoginButton.readPermissions = requiredFacebookReadPermissions()
        self.facebookLoginButton.publishPermissions = requiredFacebookWritePermissions()
        
        self.coachMarksController = CoachMarksController()
        self.coachMarksController?.datasource = self
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.coachMarksController?.startOn(self)
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
        } else {
            userInfoVerticalConstraint.constant = loggedOutVerticalConstant
        }
    }
    
    func refreshPublishPermissions(session:FBSession!) {
        
        let permissions = session.permissions as? [String] ?? [String]()
        let missingPermissions = allRequiredFacebookPermissions().filter { (element:String) -> Bool in
            return !permissions.contains(element)
        }
        
        if missingPermissions.count == 0 { return }
        
        session.requestNewPublishPermissions(missingPermissions, defaultAudience: .Everyone) { [weak self] (session:FBSession!, publishError:NSError!) -> Void in
            
            if publishError != nil {
                print(publishError)
            } else if let user = self?.facebookUser {
                
                guard let permissions = session.permissions as? [String] else { fatalError("Got weird response from server") }
                
                FacebookUserHelper.sharedHelper.singerLoggedInToFacebook(user, permissions: permissions) { [weak self] () in
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
        
        guard let permissions = FBSession.activeSession().permissions as? [String] else {
            refreshPublishPermissions(FBSession.activeSession())
            return
        }
        
        FacebookUserHelper.sharedHelper.singerLoggedInToFacebook(user, permissions: permissions) { [weak self] () -> () in
            if self?.shouldShowGroupsPicker() == true {
                self?.showGroupsPicker()
            }
        }
    }
    
    func showLoggedInUserName(user: FBGraphUser) {
        self.userFullNameLabel.text = "Logged in as \(user.name)"
        self.userFullNameLabel.font = UIFont.boldSystemFontOfSize(loggedInPointSize)
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        userFullNameLabel.text = "Log in to find your local singing"
        userFullNameLabel.font = UIFont.boldSystemFontOfSize(loggedOutPointSize)
        setConstraintsForFacebookLoginStatus(false)
    }
    
    func shouldShowGroupsPicker() -> Bool {
        if let user = PFUser.currentUser() where user[PFKey.group.rawValue] == nil && CoreDataHelper.sharedHelper.groups().count > 0 {
            return true
        }
        return false
    }
    
    func showGroupsPicker() {
        let pickerVC = GroupsPickerViewController(nibName:"GroupsPickerViewController", bundle: nil)
        self.presentViewController(pickerVC, animated: true, completion: nil)
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        
        if error.code != userCanceled {
            handleError(error)
        }
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
    
    //MARK: - Protocol Conformance | CoachMarksControllerDataSource
    func numberOfCoachMarksForCoachMarksController(coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarksForIndex index: Int) -> CoachMark {
        switch(index) {
        case 0:
            return coachMarksController.coachMarkForView(self.navigationController?.navigationBar) { (frame: CGRect) -> UIBezierPath in
                // This will make a cutoutPath matching the shape of
                // the component (no padding, no rounded corners).
                return UIBezierPath(rect: frame)
            }
        default:
            return coachMarksController.coachMarkForView()
        }
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarkViewsForIndex index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.defaultCoachViewsWithArrow(true, arrowOrientation: coachMark.arrowOrientation)
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = "Hint label"
            coachViews.bodyView.nextLabel.text = "OK"
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}
