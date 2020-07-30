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

private let characterSetToStrip = CharacterSet(charactersIn: "tb")

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
    
    convenience init(book: Book, context: NSManagedObjectContext = CoreDataHelper.managedContext) {
        self.init(className: "Song", context: context)
        
        self.book = book
    }
    
    func configureWithDict(_ dict:NSDictionary) {
        
        for (key, value) in Song.keys {
            
            if var dictValue = dict[value] as? String,
                dictValue != "null" {
                    if dictValue.hasPrefix("0") {
                        dictValue = dictValue.substring(from: 1)
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
        
        precompute()
    }
    
    override func awakeFromFetch() {
        super.awakeFromFetch()
        
        precompute()
    }
    
    func precompute() {

        if number.hasPrefix("0") {
            number = number.substring(from: 1)
        }
        
        strippedString = number.trimmingCharacters(in: characterSetToStrip)
        strippedNumber = Float(strippedString) ?? 0
        
        // t and b are in the wrong order, alphabetically
        numberForSorting = strippedNumber + Float(number.contains("b") ? 0.5 : 0)
        
        isTriple = _isTriple()
        isDuple = _isDuple()
        modeAndFormString = _modeAndFormString()
        firstLine = _firstLine()
    }
    
    private(set) var isTriple: Bool!
    private func _isTriple() -> Bool {
        if let timeSignature = timeSignature {
            let numerator = timeSignature.substring(to: 1)
            return numerator == "3" || numerator == "9"
        }
        return false
    }
    
    private(set) var isDuple: Bool!
    private func _isDuple() -> Bool {
        if let timeSignature = timeSignature {
            let numerator = timeSignature.substring(to: 1)
            return numerator != "3" && numerator != "9" && Int(numerator) != 0
        }
        return false
    }
    
    private(set) var modeAndFormString: String!
    private func _modeAndFormString() -> String {
        
        var s = ""
        if let timeSignature = timeSignature { s += timeSignature }
        if let mode = key { s += " " + mode }
        if let type = type { s += " " + type }

        return s
    }
    
    private(set) var firstLine: String?
    private func _firstLine() -> String? {
        
        guard let lyrics = lyrics else { return nil }
        let lines = lyrics.components(separatedBy: CharacterSet.newlines)
        guard let line = lines.first else { return nil }
        if line.last == "," {
            return String(line[..<line.index(before: line.endIndex)])
        }
        
        return line
    }

    //MARK: Sorting
    
    private var strippedString: String!
    private var strippedNumber: Float!
    var numberForSorting: Float!
    
    func stringForQuizQuestion(question: Quizzable) -> String? {
    
        switch question {
        case .Title:
            return title
        case .Composer:
            return formatName(composer)
        case .Lyricist:
            return formatName(lyricist)
        case .FirstLine:
            return firstLine
        case .Year:
            return (year > 0) ? "\(year)" : nil
        case .Number:
            return number
        case .ModeAndForm:
            return modeAndFormString
        }
    }
    
    func formatName(_ name: String?) -> String? {
        
        guard let name = name, name.count > 0 else {
            return nil
        }
        
        // Switch Denson, Paine --> Paine Denson
        // James, S. B. & Samuel, R. K. --> S. B. James & R. K. Samuel
        let authors = name.components(separatedBy: "&")
        
        var authorComponents = [String]()
        for author in authors { // James, S. B.
            let components = author.components(separatedBy: ",")
            authorComponents.append(components.reversed().joined(separator: " ")) // S. B. James
        }
        
        return authorComponents.joined(separator: " & ").trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "  ", with: " ")
    }
    
    func compare(_ other:Song) -> Bool {
        return numberForSorting < other.numberForSorting
    }
}
