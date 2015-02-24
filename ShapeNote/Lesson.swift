//
//  Lesson.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

@objc(Lesson)

class Lesson: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var leader: Singer
    @NSManaged var song: Song
    @NSManaged var minutes: Minutes
    
    func twitterString() -> String {
        
        var userString: String;
        
        if leader.twitter != nil && count(leader.twitter!) > 0 {
            
            userString = "Now \(leader.twitter!) is leading "
            
        } else {
            
            userString = "\(leader.name) is leading "
        }
        
        userString += "#\(song.number): \(song.title)."
        
        if (song.parts < 4) {
            userString += " #\(song.parts)parts"
        }
        if (song.key == "minor") {
            userString += " #minor"
        }
        if (song.type == "Fugue") {
            userString += " #Fugue"
        }
        
        if arc4random() % 10 == 0 {
            userString += " #shapenote"
        }
        
        if arc4random() % 10 == 0 {
            userString += " " + song.book.hashTag
        }
        
        while count(userString) > 160 {
            var components = userString.componentsSeparatedByString(" ")
            components.removeLast()
            userString = " ".join(components)
        }
        
        return userString
    }
}
