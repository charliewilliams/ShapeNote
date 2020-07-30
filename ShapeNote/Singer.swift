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
    case Bass
    case Tenor
    case Treble
    case Alto
}

func ==(first: Singer, second: Singer) -> Bool {
    return first.facebookId != nil && first.facebookId == second.facebookId
}

@objc(Singer)
class Singer: NSManagedObject {
    
    @NSManaged var displayName: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var voice: String?
    @NSManaged var twitter: String?
    @NSManaged var facebookId: String?
    @NSManaged var firstSingDate: TimeInterval
    @NSManaged var lastSingDate: TimeInterval
    @NSManaged var group: Group?
    @NSManaged var minutes: NSSet?
    
    var name: String {
        return displayName ?? firstName ?? ""
    }
    
    convenience init(context: NSManagedObjectContext = CoreDataHelper.managedContext) {
        self.init(className: "Singer", context: context)
        
        firstSingDate = NSTimeIntervalSince1970
        lastSingDate = NSTimeIntervalSince1970
        group = CoreDataHelper.sharedHelper.currentlySelectedGroup
    }
}
