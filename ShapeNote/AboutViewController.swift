//
//  AboutViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 12/11/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, EmailSender {

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
        presentEmailController(to: email, subject: subject, body: body)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
