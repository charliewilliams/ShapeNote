//
//  Book.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

@objc(Book)

class Book: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var year: String
    @NSManaged var author: String
    @NSManaged var songs: NSOrderedSet
    @NSManaged var hashTag: String
}
