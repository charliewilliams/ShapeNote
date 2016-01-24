//
//  FacebookShareViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 16/12/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class FacebookShareViewController: UIViewController, UITextViewDelegate {
    
    var minutes:Minutes!
    @IBOutlet weak var postComposeTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postButtonToBottomEdgeConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (note:NSNotification) -> Void in
            
            self?.handleKeyboardNotification(note)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (note:NSNotification) -> Void in
            
            self?.handleKeyboardNotification(note)
        }
    }
    
    func handleKeyboardNotification(note:NSNotification) {
        guard let rectValue = note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let durationValue = note.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
                return
        }
        let showing = note.name == UIKeyboardWillShowNotification
        let rect = rectValue.CGRectValue()
        let duration = durationValue.doubleValue
        let tabBarHeightIfPresent = self.navigationController?.tabBarController?.tabBar.frame.height ?? 0
//        let curve = note.valueForKey(UIKeyboardAnimationCurveUserInfoKey)
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.postButtonToBottomEdgeConstraint.constant = showing ? rect.size.height : tabBarHeightIfPresent
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (minutes != nil) {
            UIPasteboard.generalPasteboard().string = minutes.stringForSocialMedia()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        postComposeTextView.becomeFirstResponder()
    }

    func canPostToFacebook() -> Bool {
        
        let session = FBSession.activeSession()
        if session.state == .OpenTokenExtended && session.permissions != nil {
            
            let permissions = session.permissions as NSArray
            return permissions.containsObject("publish_actions")
            
        } else if !session.isOpen {
        
            session.state
            session.openWithCompletionHandler({ (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
                
                
            }, fromViewController: self)
            
            return false
        }
        
        return false
    }
    
    @IBAction func postButtonPressed(sender: UIButton) {
        
        let params = ["message": postComposeTextView.text]
        
        guard let group = CoreDataHelper.sharedHelper.currentlySelectedGroup else { return }
        let groupGraphString = "/\(group.facebookID)/feed"
        
        FBRequestConnection.startWithGraphPath(groupGraphString, parameters: params, HTTPMethod: "POST") { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            
            if error != nil {
                
                print("error \(error) posting minutes")

                self.postButton.setTitle("Error – Please Try Again", forState: .Normal)
                
            } else {
                
                self.postButton.setTitle("Post Successful", forState: .Normal)
                
                dispatch_after(2, dispatch_get_main_queue(), { [weak self] () -> Void in
                    self?.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

}
