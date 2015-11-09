//
//  QuizQuestionProvider.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

extension Set {
    func random() -> Element? {
        guard count > 0 else { return nil }
        return self[self.startIndex.advancedBy(Int(arc4random()) % count)]
    }
}

extension Array {
    func random() -> Element? {
        guard count > 0 else { return nil }
        return self[Int(arc4random()) % count]
    }
}

extension CollectionType {
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    mutating func shuffleInPlace() {
        guard count > 1 else { return }
        for i in 0..<count {
            let j = Int(arc4random()) % (count - 1)
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

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
    
    func propertyForCategory(category:Quizzable) -> String {
        switch category {
        case .Title:
            return "title"
        case .Composer:
            return "composer"
        case .Lyricist:
            return "lyricist"
        case .FirstLine:
            fatalError("No lyrics yet!")
            return "firstLine"
        case .Year:
            return "year"
        case .Number:
            return "number"
        case .ModeAndForm:
            return "modeAndFormString"
        }
    }
    
    func nextQuestion() -> QuizOption {
        
        guard let form = selectedQuestions.random() else { fatalError() }
        let questionType = form.questionType
        let answerType = form.answerType
        
        let songs = CoreDataHelper.sharedHelper.songs()
        let correctSong = songs.random()
        var selectorName = propertyForCategory(questionType)
        var selector = Selector(stringLiteral: selectorName)
        var unmanagedReturn = correctSong?.performSelector(selector)
        guard let question = unmanagedReturn?.takeUnretainedValue() as? String else { fatalError() }
        
        selectorName = propertyForCategory(answerType)
        selector = Selector(stringLiteral: selectorName)
        unmanagedReturn = correctSong?.performSelector(selector)
        guard let answer = unmanagedReturn?.takeUnretainedValue() as? String else { fatalError() }
        
        var tries = 0
        var answers = [answer]
        
        while tries < songs.count * 2 && answers.count < 4 {
            
            tries++
            let proposedSong = songs.random()
            let selectorName = propertyForCategory(answerType)
            let selector = Selector(stringLiteral: selectorName)
            if let unmanagedReturn = proposedSong?.performSelector(selector),
                let proposedAnswer = unmanagedReturn.takeUnretainedValue() as? String
                where proposedAnswer != question {
                    answers.append(proposedAnswer)
            }
        }
        
        answers.shuffleInPlace()
        guard let answerIndex = answers.indexOf(answer) else { fatalError("That would be super weird") }
        
        return QuizOption(questionType: questionType, answerType: answerType, question: question, answers:answers, answerIndex:answerIndex)
    }
}

