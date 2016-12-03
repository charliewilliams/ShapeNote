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
    
    var headerString: String {
        
        var string = "Minutes "
        
        if group.name.characters.count > 0 {
            string += "for \(group.name) on "
        } else {
            string += "– "
        }
        
        string += Minutes.dateFormatter.string(from: date)
        
        return string
    }

    func stringForSocialMedia() -> String {
        
        var string = "\(headerString):\n\n"
        
        songs.enumerateObjects({ (object:Any!, i:Int, stop:UnsafeMutablePointer<ObjCBool>) in
            
            if let lesson = object as? Lesson {
                
                string += lesson.stringForMinutes()
            }
        })
        
        if string.characters.count > 0 {
            string += "\nMinuted using the ShapeNote Companion\n"
        }
        
        return string
    }
    
}
