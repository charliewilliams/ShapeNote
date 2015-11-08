//
//  QuizQuestionProvider.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

enum Quizzable:String {
    case Title = "Title"
    case Composer = "Composer"
    case Lyricist = "Lyricist"
    case FirstLine = "First Line"
    case Year = "Year"
    case Number = "Number"
    case ModeAndForm = "Mode & Form"
}

enum QuestionVerb:String {
    case Title = "A song called"
    case Composer = "A song by"
    case Lyricist = "A song with words by"
    case FirstLine = "A song beginning with the line"
    case Year = "A song written in"
    case Number = "Song #"
    case ModeAndForm = "There is a %@ which"
}

enum AnswerVerb:String {
    case Title = "is titled"
    case Composer = "was written by"
    case Lyricist = "has words by"
    case FirstLine = "begins with the line"
    case Year = "was written in the year"
    case Number = "has the number"
    case ModeAndForm = "is a"
}

enum ModeOption {
    case Major
    case Minor
}

enum FormOption {
    case Plaintune
    case Fugue
    case Anthem
}

struct QuizOption {
    let questionType:Quizzable
    let answerType:Quizzable
    let answers:[String]?
    let correctAnswer:String?
    
    var exampleStringForQuestionPair:String {
        
        get {
            
            var s = String()
            let X = "X"
            
            switch self.questionType {
            case .Title:
                s = QuestionVerb.Title.rawValue + " \(X) "
            case .Composer:
                s = QuestionVerb.Composer.rawValue + " \(X) "
            case .Lyricist:
                s = QuestionVerb.Lyricist.rawValue + " \(X) "
            case .FirstLine:
                s = QuestionVerb.FirstLine.rawValue + " \(X) "
            case .Year:
                s = QuestionVerb.Year.rawValue + " \(X) "
            case .Number:
                s = QuestionVerb.Number.rawValue + "\(X) "
            case .ModeAndForm:
                s = String(format:QuestionVerb.ModeAndForm.rawValue, "\(X) ")
            }
            
            switch self.answerType {
            case .Title:
                s += AnswerVerb.Title.rawValue
            case .Composer:
                s += AnswerVerb.Composer.rawValue
            case .Lyricist:
                s += AnswerVerb.Lyricist.rawValue
            case .FirstLine:
                s += AnswerVerb.FirstLine.rawValue
            case .Year:
                s += AnswerVerb.Year.rawValue
            case .Number:
                s += AnswerVerb.Number.rawValue
            case .ModeAndForm:
                s += AnswerVerb.ModeAndForm.rawValue
            }
            
            s += " Y "
            
            return s
        }
    }
}

class QuizQuestionProvider {
    
    var filtering = true
    
    init() {
        _quizOptions = [String:[QuizOption]]()
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

