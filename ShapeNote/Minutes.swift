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
    
    convenience init(context: NSManagedObjectContext = CoreDataHelper.managedContext, date: Date = Date()) {
        
        self.init(className: "Minutes", context: context)
        self.date = date
    }
    
    func headerString() -> String {
        
        var string = "Minutes "
        
        if group.name.count > 0 {
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
        
        if string.count > 0 {
            string += "\nMinuted using the ShapeNote Companion\n"
        }
        
        return string
    }
    
}
