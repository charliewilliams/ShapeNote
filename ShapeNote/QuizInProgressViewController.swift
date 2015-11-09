//
//  QuizInProgressViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class QuizInProgressViewController: UIViewController {

    var currentQuestionNumber = 0
    var numberOfCorrectQuestions = 0
    let numberOfQuestionsPerRound = 2
    var question:QuizOption? {
        didSet {
            if let question = question,
            let answers = question.answers {
                self.questionLabel.text = question.exampleStringForQuestionPair
                let buttons = answerButtons()
                
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextQuestion()
    }
    
    @IBAction func answerButtonPressed(sender: UIButton) {
        
        if let index = question?.answerIndex where index == sender.tag {
            answered(true)
        } else {
            answered(false)
        }
    }
    
    func answered(correct:Bool) {
        guard let question = question else { fatalError() }
        
        if correct { numberOfCorrectQuestions++ }
        currentQuestionNumber++
        let title = correct ? "Hooray!" : "Boo…"
        let message = messageForQuestion(question, correct: correct)
        let alert = UIAlertController(title:title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Next", style: .Default, handler: { [weak self] (action:UIAlertAction) -> Void in
            self?.nextQuestion()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func messageForQuestion(question:QuizOption, correct:Bool) -> String {
        return correct ? "You got it right" : "Oops, wrong"
    }
    
    func nextQuestion() {
        
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
    
    func answerButtons() -> [UIButton] {
        return [answerButton1, answerButton2, answerButton3, answerButton4]
    }
    
}
