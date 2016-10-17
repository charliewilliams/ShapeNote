//
//  QuizQuestionProvider.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

var numberOfQuestionsPerRound = 4

extension Set {
    
    func random() -> Element? {
        guard count > 0 else { return nil }
        guard count > 1 else { return first }
        let i = index(startIndex, offsetBy: Int(arc4random_uniform(UInt32(count))))
        assert(i <= endIndex)
        return self[i]
    }
}

extension Array {
    
    func random() -> Element? {
        guard count > 0 else { return nil }
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
}

extension Collection {
    
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    
    mutating func shuffleInPlace() {
        
        guard count > 1 else { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
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
                        let a = Quizzable(rawValue: answer),
                        question != answer {
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
                "First Line":[QuizOption(questionType: .FirstLine, answerType: .Year),
                              QuizOption(questionType: .FirstLine, answerType: .Title)
            ],
        ]
    }
    
    func nextQuestion() -> QuizOption {
        
        // TODO redo this to FIRST filter the songs for matching ones
        // THEN take random ones up to answer_count
        
        let thisQuestion = selectedQuestions.random()!
        let questionType = thisQuestion.questionType
        let answerType = thisQuestion.answerType
        
        let songs = CoreDataHelper.sharedHelper.songs(inBook: .sacredHarp).shuffle()
        
        // Get all the songs that have data of this type
        let possibleSongsForThisQuestion = songs.filter { (song:Song) -> Bool in
            return song.stringForQuizQuestion(question: questionType) != nil
        }
        
        // Pick one, write down what data it holds for the answer type
        let correctSong = possibleSongsForThisQuestion.first!
        let correctQuestion = correctSong.stringForQuizQuestion(question: questionType)!
        let correctAnswer = correctSong.stringForQuizQuestion(question: answerType)!
        
        // Make an array of all songs that don't have the same data in their answer type
        let incorrectSongs = possibleSongsForThisQuestion.filter { (song:Song) -> Bool in
            
            guard let data = song.stringForQuizQuestion(question: answerType) else {
                return false
            }
            return data != correctAnswer
        }
        
        let incorrectAnswers = incorrectSongs.prefix(numberOfQuestionsPerRound - 1).flatMap { (song:Song) -> String? in
            return song.stringForQuizQuestion(question: answerType)!
        }
        
        var answers = [correctAnswer] + incorrectAnswers
        answers.shuffleInPlace()
        
        let answerIndex = answers.index(of: correctAnswer)!
        
        return QuizOption(questionType: questionType, answerType: answerType, question: correctQuestion, answers:answers, answerIndex:answerIndex)
    }
}

