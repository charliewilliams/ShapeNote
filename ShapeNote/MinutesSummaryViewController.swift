//
//  MinutesSummaryViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 16/12/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit
import Crashlytics
import MessageUI

class MinutesSummaryViewController: UIViewController, EmailSender, UITextViewDelegate {
    
    var minutes: Minutes! {
        didSet {
            UIPasteboard.general.string = minutes.stringForSocialMedia()
            title = minutes.headerString
        }
    }
    @IBOutlet weak var postComposeTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postButtonToBottomEdgeConstraint: NSLayoutConstraint!
    var observers: [NSObjectProtocol] = []
    
    deinit {
        
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }
    
    init(minutes: Minutes) {
        super.init(nibName: nil, bundle: nil)
        
        self.minutes = minutes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Answers.logContentView(withName: String(describing: self.classForCoder), contentType: nil, contentId: nil, customAttributes: ["minutes":minutes.stringForSocialMedia(), "count":minutes.songs.count])
        
        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] (note:Foundation.Notification) -> Void in
            
            self?.handleKeyboardNotification(note)
        })
        
        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] (note:Foundation.Notification) -> Void in
            
            self?.handleKeyboardNotification(note)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIPasteboard.general.string = minutes.stringForSocialMedia()
        postComposeTextView.text = minutes.stringForSocialMedia()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.resignFirstResponder()
        UIPasteboard.general.string = postComposeTextView.text
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
    
    @IBAction func sendEmailButtonPressed(_ sender: UIButton) {
        presentEmailController(to: "", subject: minutes.headerString, body: postComposeTextView.text)
    }
    
    @IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
        
        let url = URL(string: "fb://groups")!
        UIApplication.shared.openURL(url)
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
