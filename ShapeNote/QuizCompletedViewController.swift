//
//  QuizCompletedViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 09/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class QuizCompletedViewController: UIViewController {

    var numberOfQuestions = 20
    var numberCorrect = 0
    
    @IBOutlet var headlineLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var okButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //        headlineLabel.text = ??
        detailLabel.text = "You got \(numberCorrect) out of \(numberOfQuestions) right."
    }

    @IBAction func okButtonPressed(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
