//
//  Leading.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

@objc(Leading)

class Leading: NSManagedObject {

    @NSManaged var date: NSTimeInterval
    @NSManaged var leader: NSManagedObject
    @NSManaged var song: NSManagedObject

}
