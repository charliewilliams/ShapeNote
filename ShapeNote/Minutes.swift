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
    @NSManaged var complete: Bool
    
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
        
        string += dateFormatter.stringFromDate(date)
        string += ":\n\n"
        
        songs.enumerateObjectsUsingBlock { (object:AnyObject!, i:Int, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            
            if let lesson = object as? Lesson {
                
                string += lesson.stringForMinutes()
            }
        }
        
        return string
    }
    
}
