//
//  Minutes.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

@objc(Minutes)

class Minutes: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var songs: NSOrderedSet
    @NSManaged var singers: NSMutableSet
    @NSManaged var group: Group
    @NSManaged var book: Book
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        date = NSDate()
    }

    func stringForSocialMedia() -> String {
        
        var string = ""
        
//        if group.name != nil {
//            string = "Minutes for \(group.name) on "
//        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .MediumStyle
        
        string += dateFormatter.stringFromDate(NSDate())
        string += ":\n\n"
        
        songs.enumerateObjectsUsingBlock { (object:AnyObject!, i:Int, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            
            if let leading = object as? Leading {
                
                string += leading.song.number + " " + leading.song.title
                string += " – "
                
                if (leading.leader.shortName?.utf16Count > 0) {
                    string += leading.leader.shortName!
                } else {
                    string += "" + leading.leader.name
                }
                
                string += "\n"
            }
        }
        
        return string
    }
    
}
