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
    case hidden = -50
    case shown = 0
}

class QuizItemViewController: UIViewController {

    var currentQuestionNumber = 0
    var numberOfCorrectQuestions = 0
    let numberOfQuestionsPerRound = 10
    var question:QuizOption! {
        didSet {
            if let question = question,
                let answers = question.answers {
                self.questionLabel.attributedText = question.exampleStringForQuestionPair
                let buttons = answerButtons
                
                for (index, answer) in answers.enumerated() {
                    let button = buttons[index]
                    button.setTitle(answer, for: .normal)
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
        
        view.backgroundColor = backgroundImageColor
        setIndicatorsVisible(false)
        nextQuestion()
    }
    
    @IBAction func answerButtonPressed(_ sender: UIButton) {
        
        let index = question.answerIndex
        
        if index == sender.tag {
            answered(true, correctIndex:index)
        } else {
            answered(false, correctIndex:index)
        }
    }
    
    func answered(_ correct:Bool, correctIndex index:Int) {
        guard let _ = question else { fatalError() }
        
        setIndicatorsVisible(true, correctIndex: index)
        
        if correct { numberOfCorrectQuestions += 1 }
        currentQuestionNumber += 1
        
        let firstHalf = correct ? "Hooray!" : "Boo…"
        let done = (currentQuestionNumber == numberOfQuestionsPerRound)
        let secondHalf = done ? "Finish Round" : "Next Question"
        nextQuestionButton.setTitle("\(firstHalf) \(secondHalf)", for: UIControl.State())
    }
    
    @IBAction func nextQuestion() {
        
        nextButtonToBottomConstraint.constant = NextButtonConstraint.hidden.rawValue
        setIndicatorsVisible(false)
        
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
        self.present(endViewController, animated: true) { () -> Void in
            let _ = self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func finishPressed(_ sender: AnyObject) {
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func setIndicatorsVisible(_ visible:Bool, correctIndex:Int = 0) {
        
        if visible {
            
            for (index, label) in indicatorLabels.enumerated() {
                
                let center = label.center
                label.center = CGPoint(x: center.x, y: center.y - 50)
                
                if index == correctIndex {
                    label.text = tickmark
                    label.textColor = correctColor
                } else {
                    label.text = cross
                    label.textColor = wrongColor
                }
                
                UIView.animate(withDuration: 0.6, delay: TimeInterval(Double(index) / 5), usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .allowAnimatedContent, animations: { () -> Void in
                    label.alpha = 1
                    label.center = center
                    }, completion: nil)
                
                UIView.animate(withDuration: 0.3, delay: TimeInterval(0.8), options: .allowAnimatedContent, animations: { () -> Void in
                    self.nextButtonToBottomConstraint.constant = NextButtonConstraint.shown.rawValue
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
