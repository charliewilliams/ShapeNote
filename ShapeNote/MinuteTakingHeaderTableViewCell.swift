//
//  MinuteTakingHeaderTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 14/11/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

class MinuteTakingHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var liveTweetLabel: UILabel!
    @IBOutlet weak var liveTweetSwitch: UISwitch!
    @IBOutlet weak var twitterIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        liveTweetLabel.text = nil
        
        startTwitter()
    }
    
    @IBAction func liveTweetSwitchChanged(_ sender: UISwitch) {
        
        Defaults.hasTwitter = sender.isOn
        
        if sender.isOn {
            
            startTwitter()
            
        } else {

            setUpTwitter(forUserName: nil)
        }
    }
    
    func startTwitter() {
        
        TwitterShareHelper.setUpTwitter() { [weak self] userName in
            self?.setUpTwitter(forUserName: userName)
        }
    }
    
    func setUpTwitter(forUserName userName: String?) {
        
        if let userName = userName {
            
            liveTweetLabel.text = "Live tweeting as @\(userName)"
            liveTweetLabel.textColor = blueColor
            liveTweetSwitch.isOn = true

            twitterIconImageView.image = #imageLiteral(resourceName: "twtr-icn-logo.png")
            twitterIconImageView.tintColor = .white
            
        } else {
            
            liveTweetLabel.text = "Live-tweeting: off"
            liveTweetLabel.textColor = .gray
            liveTweetSwitch.isOn = false
            
            twitterIconImageView.image = #imageLiteral(resourceName: "twtr-icn-logo.png").withRenderingMode(.alwaysTemplate)
            twitterIconImageView.tintColor = .gray
        }
    }
}
