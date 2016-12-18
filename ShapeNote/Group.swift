//
//  Group.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

@objc(Group)
class Group: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var singers: [Singer]
    @NSManaged var facebookID: String
    
     convenience init(name: String, facebookID: String? = nil, context: NSManagedObjectContext = CoreDataHelper.managedContext) {
        self.init(className: "Group", context: context)
        
        self.name = name
        if let facebookID = facebookID {
            self.facebookID = facebookID
        }
    }
}
