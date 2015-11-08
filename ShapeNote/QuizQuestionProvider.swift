//
//  QuizQuestionProvider.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

class QuizQuestionProvider {
    
    var filtering = true
    var selectedQuestions:Set<QuizOption>
    
    class var sharedProvider : QuizQuestionProvider {
        struct Static {
            static let instance : QuizQuestionProvider = QuizQuestionProvider()
        }
        return Static.instance
    }
    
    init() {
        _quizOptions = [String:[QuizOption]]()
        selectedQuestions = Set<QuizOption>()
    }
    
    var questionTypes:[String] {
        
        if filtering {
            return Array(filteredOptions.keys)
        }
        return ["Title", "Composer", "Lyricist", "First Line", "Year", "Number", "Mode & Form"]
    }
    
    var _quizOptions:[String:[QuizOption]]
    var quizOptions:[String:[QuizOption]] {
        
        get {
            
            if filtering {
                return filteredOptions
            }
            
            if _quizOptions.keys.count > 0 { return _quizOptions }
            
            _quizOptions = [String:[QuizOption]]()

            for question in questionTypes {
                
                var theseOptions = [QuizOption]()
                
                for answer in questionTypes {
                    if let q = Quizzable(rawValue: question),
                        let a = Quizzable(rawValue: answer)
                        where question != answer {
                            theseOptions.append(QuizOption(questionType: q, answerType: a, answers: nil, correctAnswer: nil))
                    }
                }
                
                _quizOptions[question] = theseOptions
            }
            
            return _quizOptions
        }
    }
    
    var filteredOptions:[String:[QuizOption]] {
        return ["Title":[QuizOption(questionType: .Title, answerType: .Number, answers: nil, correctAnswer: nil),
            QuizOption(questionType: .Title, answerType: .FirstLine, answers: nil, correctAnswer: nil),
            QuizOption(questionType: .Title, answerType: .Composer, answers: nil, correctAnswer: nil),
            ],
            "Number":[QuizOption(questionType: .Number, answerType: .Title, answers: nil, correctAnswer: nil),
            QuizOption(questionType: .Number, answerType: .ModeAndForm, answers: nil, correctAnswer: nil),
            ],
            "First Line":[QuizOption(questionType: .FirstLine, answerType: .Year, answers: nil, correctAnswer: nil)]
            
        ]
    }
}

