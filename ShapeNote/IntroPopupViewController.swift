//
//  IntroPopupViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 22/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class IntroPopupViewController: UIViewController {
    
    @IBOutlet var doneButton: UIButton!
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        Defaults.isFirstRun = false
        self.dismiss(animated: true) { () -> Void in
        }
    }
}
