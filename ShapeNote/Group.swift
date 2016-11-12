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
    
    class func create(name: String, facebookID: String? = nil) -> Group {
        
        let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: CoreDataHelper.managedContext) as! Group
        group.name = name
        if let facebookID = facebookID {
            group.facebookID = facebookID
        }
        
        return group
    }
}
