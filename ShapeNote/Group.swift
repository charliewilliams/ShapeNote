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
    @NSManaged var singer: Singer

}
