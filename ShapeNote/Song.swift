//
//  Song.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

enum SortType: String {
    case number
    case popularity
    case date
}

enum SortOrder: String {
    case ascending
    case descending
}

func sortDescription(forType sortType: SortType, order: SortOrder) -> String {
    if order == .ascending {
        return "\(sortType)"
    } else {
        return "\(sortType) - \(order)"
    }
}

@objc(Song)
class Song: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var composer: String?
    @NSManaged var lyricist: String?
    @NSManaged var year: Int16
    @NSManaged var number: String
    @NSManaged var type: String?
    @NSManaged var timeSignature: String?
    @NSManaged var meter: String?
    @NSManaged var parts: Int16
    @NSManaged var key: String?
    @NSManaged var book: Book
    @NSManaged var ledBy: Lesson
    @NSManaged var favorited: Bool
    @NSManaged var notes: String?
    @NSManaged var lyrics: String?
    @NSManaged var popularity: Int16
    
    class var keys: [String:String] {
        
        //[{"Number":"073b","Song Title":"Arlington","Key":"Major","Fugue/Plain":"Plain","Time Signature":"3/2","Meter":"CM","Parts":4,"Year":1762,"Composer":"Arne, Thomas A.","Lyricist":null, "popularity":176},
        return ["number":"Number",
            "title":"Song Title",
            "composer":"Composer",
            "lyricist":"Lyricist",
            "year":"Year",
            "type":"Fugue/Plain",
            "timeSignature":"Time Signature",
            "meter":"Meter",
            "parts":"Parts",
            "source":"Source Abbr.",
            "key":"Key",
            "lyrics":"lyrics",
            "popularity":"popularity"]
    }
    
    func configureWithDict(_ dict:NSDictionary) {
        
        for (key, value) in Song.keys {
            
            if var dictValue = dict[value] as? String,
                dictValue != "null" {
                    if dictValue.hasPrefix("0") {
                        dictValue = dictValue.substring(from: dictValue.index(after: dictValue.startIndex))
                    }
                    self.setValue(dictValue, forKey: key)
                    
            } else if let dictNumber = dict[value] as? NSNumber,
                dictNumber.intValue != 0 {
                    self.setValue(dictNumber.intValue, forKey: key)
            } else if let dictArray = dict[value] as? [String] {
                let lyrics = dictArray.joined(separator: "\n")
                self.setValue(lyrics, forKey: key)
            }
        }
    }
    
    var isTriple: Bool {
        if let timeSignature = timeSignature {
            let index = timeSignature.characters.index(timeSignature.startIndex, offsetBy: 1)
            let numerator = timeSignature.substring(to: index)
            return numerator == "3" || numerator == "9"
        }
        return false
    }
    
    var isDuple: Bool {
        if let timeSignature = timeSignature {
            let index = timeSignature.characters.index(timeSignature.startIndex, offsetBy: 1)
            let numerator = timeSignature.substring(to: index)
            return numerator != "3" && numerator != "9" && Int(numerator) != 0
        }
        return false
    }
    
    var modeAndFormString: String {
        
        var s = ""
        if let timeSignature = timeSignature { s += timeSignature }
        if let mode = key { s += " " + mode }
        if let type = type { s += " " + type }

        return s
    }
    
    var firstLine: String? {
        
        guard let lyrics = lyrics else { return nil }
        let lines = lyrics.components(separatedBy: CharacterSet.newlines)
        guard let line = lines.first else { return nil }
        if line.characters.last == "," {
            return line.substring(to: line.characters.index(before: line.endIndex))
        }
        
        return line
    }
    
    func popularityAsPercentOfTotalSongs(_ totalSongs:Int) -> Float {
        assert(totalSongs > 0)
        return Float(popularity) / Float(totalSongs)
    }

    //MARK: Sorting
    
    var strippedNumber: Float {
        
        let characterSet:CharacterSet = CharacterSet(charactersIn: "tb")
        let strippedString = self.number.trimmingCharacters(in: characterSet)
        return Float(strippedString)!
    }
    
    var numberForSorting: Float {
        
        // add 0.5 to bottom tunes so they get sorted second
        let addition = Float(number.contains("b") ? 0.5 : 0)
        return strippedNumber + addition
    }
    
    func stringForQuizQuestion(question: Quizzable) -> String? {
    
        switch question {
        case .Title: return title
        case .Composer: return composer
        case .Lyricist: return lyricist
        case .FirstLine: return firstLine
        case .Year: return (year > 0) ? "\(year)" : nil
        case .Number: return number
        case .ModeAndForm: return modeAndFormString
        }
    }
    
    func compare(_ other:Song) -> Bool {
        // t and b are in the wrong order, alphabetically
        if (strippedNumber == other.strippedNumber) {
            return number.compare(other.number) == ComparisonResult.orderedDescending
        } else {
            return strippedNumber < other.strippedNumber
        }
    }
}
