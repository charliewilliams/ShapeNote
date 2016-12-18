//
//  Book.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

enum BookIdentifier: String {
    case sacredHarp = "The Sacred Harp (1991)"
    case cooper = "The Sacred Harp (Cooper, 2012)"
    case shenandoah = "The Shenandoah Harmony (2012)"
    case christianHarmony = "The Christian Harmony (2010)"
}

@objc(Book) class Book: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var shortTitle: String
    @NSManaged var year: String
    @NSManaged var author: String
    @NSManaged var songs: NSOrderedSet
    @NSManaged var hashTag: String
    
    convenience init(identifier: BookIdentifier, context: NSManagedObjectContext = CoreDataHelper.managedContext) {
        self.init(className: "Book", context: context)
        
        self.title = identifier.rawValue
    }
}
