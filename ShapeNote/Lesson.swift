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

    @NSManaged var date: Date
    @NSManaged var leader: NSOrderedSet //[Singer]
    @NSManaged var song: Song
    @NSManaged var minutes: Minutes
    @NSManaged var dedication: String?
    @NSManaged var otherEvent: String?
    
    func stringForMinutes() -> String {
        
        var string = song.number + " " + song.title
        string += " – "
        string += allLeadersString(useTwitterHandles: false)
        if let ded = dedication {
            string += " (\(ded))"
        }
        string += "\n"
        return string
    }
    
    func allLeadersString(useTwitterHandles:Bool) -> String {
        
        var leadersString = ""
        let first:Singer = leader.firstObject! as! Singer
        let last:Singer = leader.lastObject! as! Singer
        
        if first != last {
            
            leader.enumerateObjects({ (element:AnyObject, index:Int, done:UnsafeMutablePointer<ObjCBool>) -> Void in
                
                if let singer = element as? Singer {
                    
                    let name:String;
                    
                    if (useTwitterHandles == true && singer.twitter != nil) {
                        name = singer.twitter!
                    } else {
                        name = singer.firstName ?? singer.name
                    }
                    
                    switch index {
                        
                    case 0:
                        leadersString = name
                        
                    case self.leader.count-1:
                        leadersString += " & \(name)"
                        
                    default:
                        leadersString += ", \(name)"
                    }
                }
            } as! (Any, Int, UnsafeMutablePointer<ObjCBool>) -> Void)
            
        } else {
            
            leadersString = useTwitterHandles ? (first.twitter ?? first.name) : first.name
        }

        return leadersString
    }
    
    func twitterString() -> String {
        
        var userString = "Now "
        
        userString += allLeadersString(useTwitterHandles: true)
        
        userString += leader.count == 1 ? " is leading " : " are leading "
        
        var number = song.number
        if number.hasPrefix("0") {
            number = number.substring(from: number.index(after: number.startIndex))
        }
        userString += "#\(number): \(song.title)"
        
        if dedication != nil {
            userString += " (\(dedication!))"
        }
        
        userString += "."
        
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
        
        while userString.characters.count > 160 {
            var components = userString.components(separatedBy: " ")
            components.removeLast()
            userString = components.joined(separator: " ")
        }
        
        return userString
    }
}
