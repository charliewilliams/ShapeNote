//
//  EmailSender.swift
//  ShapeNote
//
//  Created by Charlie Williams on 03/12/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import MessageUI

protocol EmailSender: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
}

extension EmailSender where Self: UIViewController {
    
    func presentEmailController(to email: String, subject: String, body: String) {
        
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
}
