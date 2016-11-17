//
//  MinuteTakingHeaderTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 14/11/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit
import TwitterKit

class MinuteTakingHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var liveTweetLabel: UILabel!
    @IBOutlet weak var liveTweetSwitch: UISwitch!
    @IBOutlet weak var twitterIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        liveTweetLabel.text = nil
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if Defaults.hasTwitter || Twitter.sharedInstance().sessionStore.session() != nil{
            logIntoTwitter()
        } else {
            setUpTwitter(withSession: nil)
        }
    }
    
    @IBAction func liveTweetSwitchChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            
            let store = Twitter.sharedInstance().sessionStore
            if let userId = store.session()?.userID {
                store.logOutUserID(userId)
            }
            setUpTwitter(withSession: nil)
            
        } else {
            
            logIntoTwitter()
        }
    }
    
    func logIntoTwitter() {
        Twitter.sharedInstance().logIn { [weak self] (session:TWTRSession?, error:Error?) in
            self?.setUpTwitter(withSession: session)
        }
    }

    func setUpTwitter(withSession session: TWTRSession?) {
        
        if let username = session?.userName {
            
            Defaults.hasTwitter = true
            liveTweetLabel.text = "Live tweeting as @\(username)"
            liveTweetLabel.textColor = blueColor
            liveTweetSwitch.isOn = true

            twitterIconImageView.image = #imageLiteral(resourceName: "twtr-icn-logo.png")
            twitterIconImageView.tintColor = .white
            
        } else {
            
            Defaults.hasTwitter = false
            liveTweetLabel.text = "Live-tweeting: off"
            liveTweetLabel.textColor = .gray
            liveTweetSwitch.isOn = false
            
            twitterIconImageView.tintColor = .gray
            twitterIconImageView.image = #imageLiteral(resourceName: "twtr-icn-logo.png").withRenderingMode(.alwaysTemplate)
        }
        

    }
}
