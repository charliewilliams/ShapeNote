//
//  QuizItemViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

let tickmark = "✔︎"
let cross = "✘"
let correctColor = UIColor(red: 0.004, green: 0.788, blue: 0, alpha: 1)
let wrongColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)

enum NextButtonConstraint: CGFloat {
    case Hidden = -50
    case Shown = 50
}

class QuizItemViewController: UIViewController {

    var currentQuestionNumber = 0
    var numberOfCorrectQuestions = 0
    let numberOfQuestionsPerRound = 10
    var question:QuizOption? {
        didSet {
            if let question = question,
            let answers = question.answers {
                self.questionLabel.attributedText = question.exampleStringForQuestionPair
                let buttons = answerButtons
                
                for (index, answer) in answers.enumerate() {
                    let button = buttons[index]
                    button.setTitle(answer, forState: .Normal)
                }
            }
        }
    }
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerButton1: UIButton!
    @IBOutlet var answerButton2: UIButton!
    @IBOutlet var answerButton3: UIButton!
    @IBOutlet var answerButton4: UIButton!
    
    @IBOutlet var answerIndicatorLabel1: UILabel!
    @IBOutlet var answerIndicatorLabel2: UILabel!
    @IBOutlet var answerIndicatorLabel3: UILabel!
    @IBOutlet var answerIndicatorLabel4: UILabel!
    
    @IBOutlet var nextQuestionButton: UIButton!
    @IBOutlet var nextButtonToBottomConstraint: NSLayoutConstraint!
    
    var indicatorLabels:[UILabel] {
        return [answerIndicatorLabel1, answerIndicatorLabel2, answerIndicatorLabel3, answerIndicatorLabel4]
    }
    
    var answerButtons:[UIButton] {
        return [answerButton1, answerButton2, answerButton3, answerButton4]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndicatorsVisible(false, correctIndex:0)
        nextQuestion()
    }
    
    @IBAction func answerButtonPressed(sender: UIButton) {
        
        guard let index = question?.answerIndex else { fatalError() }
        
        if index == sender.tag {
            answered(true, correctIndex:index)
        } else {
            answered(false, correctIndex:index)
        }
    }
    
    func answered(correct:Bool, correctIndex index:Int) {
        guard let _ = question else { fatalError() }
        
        setIndicatorsVisible(true, correctIndex: index)
        
        if correct { numberOfCorrectQuestions++ }
        currentQuestionNumber++
        
        let firstHalf = correct ? "Hooray!" : "Boo…"
        let done = (currentQuestionNumber == numberOfQuestionsPerRound)
        let secondHalf = done ? "Finish Round" : "Next Question"
        nextQuestionButton.setTitle("\(firstHalf) \(secondHalf)", forState: .Normal)
    }
    
    @IBAction func nextQuestion() {
        
        nextButtonToBottomConstraint.constant = NextButtonConstraint.Hidden.rawValue
        setIndicatorsVisible(false, correctIndex: 0)
        
        guard currentQuestionNumber < numberOfQuestionsPerRound else {
            finishRound()
            return
        }
        title = "\(currentQuestionNumber + 1)/\(numberOfQuestionsPerRound)"
        if currentQuestionNumber > 0 {
            let percentCorrect = Double(numberOfCorrectQuestions) / Double(currentQuestionNumber)
            let pc = Int(percentCorrect * 100.0)
            title = title! + "… \(pc)%"
        }
        
        question = QuizQuestionProvider.sharedProvider.nextQuestion()
    }
    
    func finishRound() {
        let endViewController = QuizCompletedViewController()
        endViewController.numberCorrect = numberOfCorrectQuestions
        endViewController.numberOfQuestions = numberOfQuestionsPerRound
        self.presentViewController(endViewController, animated: true) { () -> Void in
            self.navigationController?.popViewControllerAnimated(false)
        }
    }
    
    @IBAction func finishPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func setIndicatorsVisible(visible:Bool, correctIndex:Int) {
        
        if visible {
            
            for (index, label) in indicatorLabels.enumerate() {
                
                let center = label.center
                label.center = CGPointMake(center.x, center.y - 50)
                
                if index == correctIndex {
                    label.text = tickmark
                    label.textColor = correctColor
                } else {
                    label.text = cross
                    label.textColor = wrongColor
                }
                
                UIView.animateWithDuration(0.6, delay: NSTimeInterval(Double(index) / 5), usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .AllowAnimatedContent, animations: { () -> Void in
                    label.alpha = 1
                    label.center = center
                    }, completion: nil)
                
                UIView.animateWithDuration(0.3, delay: NSTimeInterval(0.8), options: .AllowAnimatedContent, animations: { () -> Void in
                    self.nextButtonToBottomConstraint.constant = NextButtonConstraint.Shown.rawValue
                    self.view.layoutIfNeeded()
                    }, completion: nil)
                }
            
        } else {
            
            for label in indicatorLabels {
                label.alpha = 0
            }
        }
    }
    
}
