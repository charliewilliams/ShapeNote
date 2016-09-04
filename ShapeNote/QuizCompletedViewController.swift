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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        headlineLabel.text = phraseForScore().string
//        backgroundImageView.image = phraseForScore().image
        detailLabel.text = "You got\n\(numberCorrect)\nout of\n\(numberOfQuestions)\nright."
    }
    
    func phraseForScore() -> (string:String, image:String?) {
        
        let percent = Float(numberCorrect) / Float(numberOfQuestions)
        
        switch percent {
        case 0.0..<0.1:
            return ("Try again", nil)
        case 0.1..<0.3:
            return ("Tough Times", nil)
        case 0.3..<0.5:
            return ("Nice try", nil)
        case 0.5..<0.7:
            return ("Nice work", nil)
        case 0.7..<0.9:
            return ("Great job", nil)
        case 0.9..<1.0:
            return ("Super!", nil)
        case 1.0:
            return ("Perfect Score!", nil)
        default:
            fatalError()
        }
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
