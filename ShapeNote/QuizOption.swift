//
//  QuizOption.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

enum Quizzable: String {
    case Title
    case Composer
    case Lyricist
    case FirstLine = "First Line"
    case Year
    case Number
    case ModeAndForm = "Mode & Form"
}

enum QuestionVerb: String {
    case Title = ""
    case Composer = "A song by"
    case Lyricist = "A song with words by"
    case FirstLine = "A song beginning with the line"
    case Year = "A song written in"
    case Number = "Song #"
    case ModeAndForm = "There is a %@ which"
}

enum AnswerVerb: String {
    case Title = "is titled"
    case Composer = "was written by"
    case Lyricist = "has words by"
    case FirstLine = "begins with the line"
    case Year = "was written in the year"
    case Number = "is song number"
    case ModeAndForm = "is a"
}

enum ModeOption: String {
    case Major = "Major"
    case Minor = "Minor"
}

enum FormOption: String {
    case Plaintune = "Plaintune"
    case Fugue = "Fugue"
    case Anthem = "Anthem"
}

func ==(lhs: QuizOption, rhs: QuizOption) -> Bool {
    return lhs.questionType == rhs.questionType && lhs.answerType == rhs.answerType
}

struct QuizOption: Hashable {
    let questionType: Quizzable
    let answerType: Quizzable
    let question: String?
    var answers: [String]?
    var answerIndex: Int = 0
    
    init(questionType: Quizzable, answerType: Quizzable) {
        self.questionType = questionType
        self.answerType = answerType
        question = nil
        answers = nil
    }
    
    init(questionType: Quizzable, answerType: Quizzable, question: String?, answers: [String]?, answerIndex: Int) {
        self.questionType = questionType
        self.answerType = answerType
        self.question = question
        self.answers = answers
        self.answerIndex = answerIndex
    }
    
    var itemStringForQuestionPair: String {
        switch self.answerType {
        case .Title:
            return "…what's the title?"
        case .Composer:
            return "…who's the composer?"
        case .Lyricist:
            return "…who wrote the words?"
        case .FirstLine:
            return "…what's the first line?"
        case .Year:
            return "…what year was it written?"
        case .Number:
            return "…what number is it?"
        case .ModeAndForm:
            return "…what's the mode and form?"
        }
    }
    
    var exampleStringForQuestionPair: NSAttributedString {
        var s = String()
        let X = (question != nil) ? question! : "X"
        
        switch self.questionType {
        case .Title:
            s = QuestionVerb.Title.rawValue + "\(X) "
        case .Composer:
            // Composer names are written Last, First
            // but that's annoying to read in the quiz
            var nameElements = X.components(separatedBy: ",")
            nameElements = nameElements.reversed()
            s = QuestionVerb.Composer.rawValue + " \(nameElements.joined(separator: " ")) "
        case .Lyricist:
            s = QuestionVerb.Lyricist.rawValue + " \(X) "
        case .FirstLine:
            s = QuestionVerb.FirstLine.rawValue + "\n\"\(X)\" "
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
        
        s += ":"
        
        let fontName = "HoeflerText-Regular"
        let fontNameItalic = "HoeflerText-Italic"
        let italics = [NSFontAttributeName: UIFont(name: fontNameItalic, size: 24)!]
        let nonItalics = [NSFontAttributeName: UIFont(name: fontName, size: 24)!]
        
        let nsstring = NSString(string: s)
        let range = nsstring.range(of: X)
        
        let attrQuestion = NSMutableAttributedString(string: s, attributes: nonItalics)
        attrQuestion.addAttributes(italics, range: range)
        
        return attrQuestion
    }
    
    var hashValue: Int {
        return questionType.hashValue + answerType.hashValue
    }
}
