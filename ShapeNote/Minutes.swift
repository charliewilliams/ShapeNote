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

    @NSManaged var date: Date
    @NSManaged var songs: NSOrderedSet
    @NSManaged var singers: NSMutableSet
    @NSManaged var group: Group
    @NSManaged var book: Book
    @NSManaged var complete: Bool
    static let dateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.timeStyle = .none
        d.dateStyle = .medium
        return d
    }()
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) {
        super.init(entity: entity, insertInto: context)
        date = Date()
    }

    func stringForSocialMedia() -> String {
        
        var string = ""
        
//        if group.name != nil {
//            string = "Minutes for \(group.name) on "
//        }
        
        string += Minutes.dateFormatter.string(from: date)
        string += ":\n\n"
        
        songs.enumerateObjects({ (object:Any!, i:Int, stop:UnsafeMutablePointer<ObjCBool>) in
            
            if let lesson = object as? Lesson {
                
                string += lesson.stringForMinutes()
            }
        })
        
        return string
    }
    
}
