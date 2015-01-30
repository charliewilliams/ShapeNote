//
//  Singer.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

class Singer: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var shortName: String
    @NSManaged var twitter: String
    @NSManaged var facebook: String
    @NSManaged var firstSingDate: NSTimeInterval
    @NSManaged var lastSingDate: NSTimeInterval
    @NSManaged var group: NSManagedObject
    @NSManaged var songs: Leading

}
