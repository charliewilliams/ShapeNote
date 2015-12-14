//
//  Song.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

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
    
    func configureWithDict(dict:NSDictionary) {
        
        for (key, value) in Song.keys {
            
            if var dictValue = dict[value] as? String
                where dictValue != "null" {
                    if dictValue.hasPrefix("0") {
                        dictValue = dictValue.substringFromIndex(dictValue.startIndex.successor())
                    }
                    self.setValue(dictValue, forKey: key)
                    
            } else if let dictNumber = dict[value] as? NSNumber
                where dictNumber.integerValue != 0 {
                    self.setValue(dictNumber.integerValue, forKey: key)
            } else if let dictArray = dict[value] as? [String] {
                let lyrics = dictArray.joinWithSeparator("\n")
                self.setValue(lyrics, forKey: key)
            }
        }
    }
    
    func isTriple() -> Bool {
        if let timeSignature = timeSignature {
            let index = timeSignature.startIndex.advancedBy(1)
            let numerator = timeSignature.substringToIndex(index)
            return numerator == "3" || numerator == "9"
        }
        return false
    }
    
    func isDuple() -> Bool {
        if let timeSignature = timeSignature {
            let index = timeSignature.startIndex.advancedBy(1)
            let numerator = timeSignature.substringToIndex(index)
            return numerator != "3" && numerator != "9" && Int(numerator) != 0
        }
        return false
    }
    
    func modeAndFormString() -> String {
        
        var s = ""
        if let timeSignature = timeSignature { s += timeSignature }
        if let mode = key { s += " " + mode }
        if let type = type { s += " " + type }

        return s
    }
    
    func firstLine() -> String? {
        
        guard let lyrics = lyrics else { return nil }
        let lines = lyrics.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        guard let line = lines.first else { return nil }
        if line.characters.last == "," {
            return line.substringToIndex(line.endIndex.predecessor())
        }
        
        return line
    }
    
    func popularityAsPercentOfTotalSongs(totalSongs:Int) -> Float {
        assert(totalSongs > 0)
        return Float(popularity) / Float(totalSongs)
    }

    //MARK: Sorting
    
    var strippedNumber: String {
        
        let characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "tb")
        return self.number.stringByTrimmingCharactersInSet(characterSet)
    }
    
    func compare(other:Song) -> Bool {
        // t and b are in the wrong order, alphabetically
        if (strippedNumber == other.strippedNumber) {
            return number.compare(other.number) == NSComparisonResult.OrderedDescending
        } else {
            return Int(strippedNumber)! < Int(other.strippedNumber)!
        }
    }
}
