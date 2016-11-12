//
//  AboutViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 12/11/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    let email = "c@charliewilliams.org"
    let subject = "Shapenote Companion App"
    let body = "Hi Charlie!\n\n"
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var mainTextView: UITextView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mainTextView.setContentOffset(.zero, animated: false)
        faceImageView.layer.cornerRadius = faceImageView.bounds.width / 2
    }
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        
        guard MFMailComposeViewController.canSendMail() else {
            
            let urlString = "inbox-gmail://co?to=\(email)&subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: CharacterSet.whitespacesAndNewlines.inverted)!
            let url = URL(string: urlString)!
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        composeVC.setToRecipients([email])
        composeVC.setSubject(subject)
        composeVC.setMessageBody(body, isHTML: false)
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
