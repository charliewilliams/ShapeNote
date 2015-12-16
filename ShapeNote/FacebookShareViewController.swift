//
//  FacebookShareViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 16/12/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class FacebookShareViewController: UIViewController {

    class func canPostToFacebook() -> Bool {
        
        let permissions:NSArray = FBSession.activeSession().permissions
        return permissions.containsObject("publish_actions")
    }
    
    func postMinutesToFacebook(minutes:Minutes) {
        
        let params = ["message": minutes.stringForSocialMedia()]
        
        guard let group = CoreDataHelper.sharedHelper.currentlySelectedGroup else { return }
        let groupGraphString = "/\(group.facebookID)/feed"
        
        UIPasteboard.generalPasteboard().string = minutes.stringForSocialMedia()
        
        // Show UI saying "write your message here…"
        
        FBRequestConnection.startWithGraphPath(groupGraphString, parameters: params, HTTPMethod: "POST") { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            
            if error != nil {
                
                print("error \(error) posting minutes")
                // TODO handle error in UI
                
            } else {
                
                print("posted minutes: \(result)")
            }
        }
    }

}
