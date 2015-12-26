//
//  FacebookShareViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 16/12/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class FacebookShareViewController: UIViewController {
    
    var minutes:Minutes!
    @IBOutlet weak var postComposeTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIPasteboard.generalPasteboard().string = minutes.stringForSocialMedia()
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

}
