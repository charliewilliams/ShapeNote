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
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] (note:Foundation.Notification) -> Void in
            
            self?.handleKeyboardNotification(note)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] (note:Foundation.Notification) -> Void in
            
            self?.handleKeyboardNotification(note)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (minutes != nil) {
            UIPasteboard.general.string = minutes.stringForSocialMedia()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        postComposeTextView.becomeFirstResponder()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func handleKeyboardNotification(_ note:Foundation.Notification) {
        guard let rectValue = (note as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let durationValue = (note as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
                return
        }
        let showing = note.name == NSNotification.Name.UIKeyboardWillShow
        let rect = rectValue.cgRectValue
        let duration = durationValue.doubleValue
        let tabBarHeightIfPresent = self.navigationController?.tabBarController?.tabBar.frame.height ?? 0
        //        let curve = note.valueForKey(UIKeyboardAnimationCurveUserInfoKey)
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.postButtonToBottomEdgeConstraint.constant = showing ? rect.size.height : tabBarHeightIfPresent
            self.view.layoutIfNeeded()
        })
    }
}
