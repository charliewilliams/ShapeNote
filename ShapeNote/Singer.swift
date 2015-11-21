//
//  Singer.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

enum Voice: String {
    case NotSpecified = ""
    case Bass = "Bass"
    case Tenor = "Tenor"
    case Treble = "Treble"
    case Alto = "Alto"
}

@objc(Singer)

class Singer: NSManagedObject {
    
    @NSManaged var displayName: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var voice: String?
    @NSManaged var twitter: String?
    @NSManaged var facebook: String?
    @NSManaged var firstSingDate: NSTimeInterval
    @NSManaged var lastSingDate: NSTimeInterval
    @NSManaged var group: Group?
    @NSManaged var songs: Lesson?
    @NSManaged var minutes: NSSet?
    
    var name:String {
        return displayName ?? firstName ?? ""
    }
}
