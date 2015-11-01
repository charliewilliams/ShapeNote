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
    
    class var keys: [String:String] {
        
        //[{"Number":"073b","Song Title":"Arlington","Key":"Major","Fugue/Plain":"Plain","Time Signature":"3/2","Meter":"CM","Parts":4,"Year":1762,"Composer":"Arne, Thomas A.","Lyricist":null},
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
            "key":"Key"]
    }
    
    var strippedNumber: String {
        
        let characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "tb")
        return self.number.stringByTrimmingCharactersInSet(characterSet)
    }
    
    func configureWithDict(dict:NSDictionary) {
        
        for (key, value) in Song.keys {
            
            if let dictValue = dict[value] as? String
                where dictValue != "null" {
                self.setValue(dictValue, forKey: key)
                
            } else if let dictNumber = dict[value] as? NSNumber
                where dictNumber.integerValue != 0 {
                    self.setValue(dictNumber.integerValue, forKey: key)
            }
        }
    }
}
