//
//  QuizQuestionProvider.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

var numberOfQuestionsPerRound = 4

class QuizQuestionProvider {
    
    var selectedQuestions: Set<QuizOption>
    
    static var sharedProvider: QuizQuestionProvider {
        struct Static {
            static let instance: QuizQuestionProvider = QuizQuestionProvider()
        }
        return Static.instance
    }
    
    init() {
        _quizOptions = [String: [QuizOption]]()
        selectedQuestions = Set<QuizOption>()
    }
    
    let questionTypes = ["Title", "Number", "Composer", "Lyricist", "First Line", "Mode & Form", "Year"]
    
    var _quizOptions: [String: [QuizOption]]
    var quizOptions: [String: [QuizOption]] {
        
        if _quizOptions.keys.count > 0 { return _quizOptions }
        
        _quizOptions = [String:[QuizOption]]()
        
        for question in questionTypes {
            
            _quizOptions[question] = questionTypes.compactMap { answer -> QuizOption? in
                
                if let q = Quizzable(rawValue: question),
                    let a = Quizzable(rawValue: answer),
                    question != answer {
                    return QuizOption(questionType: q, answerType: a)
                }
                return nil
            }
        }
        
        return _quizOptions
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
            return song.stringForQuizQuestion(question: questionType) != nil &&
                song.stringForQuizQuestion(question: answerType) != nil
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
        
        let incorrectAnswers = incorrectSongs.prefix(numberOfQuestionsPerRound - 1).compactMap { (song:Song) -> String? in
            return song.stringForQuizQuestion(question: answerType)
        }
        
        var answers = [correctAnswer] + incorrectAnswers
        answers.shuffleInPlace()
        
        let answerIndex = answers.firstIndex(of: correctAnswer)!
        
        return QuizOption(questionType: questionType, answerType: answerType, question: correctQuestion, answers:answers, answerIndex:answerIndex)
    }
}

