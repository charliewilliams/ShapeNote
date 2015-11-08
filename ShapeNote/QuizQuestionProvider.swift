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
                            theseOptions.append(QuizOption(questionType: q, answerType: a))
                    }
                }
                
                _quizOptions[question] = theseOptions
            }
            
            return _quizOptions
        }
    }
    
    var filteredOptions:[String:[QuizOption]] {
        return ["Title":[QuizOption(questionType: .Title, answerType: .Number),
            QuizOption(questionType: .Title, answerType: .FirstLine),
            QuizOption(questionType: .Title, answerType: .Composer),
            ],
            "Number":[QuizOption(questionType: .Number, answerType: .Title),
            QuizOption(questionType: .Number, answerType: .ModeAndForm),
            ],
            "First Line":[QuizOption(questionType: .FirstLine, answerType: .Year)]
            
        ]
    }
    
    func nextQuestion() -> QuizOption {
        return QuizOption(questionType: .Title, answerType: .Number, question: "What number is Evening Shade?", answers: ["271", "83", "1", "399"], answerIndex: 0)
    }
}

