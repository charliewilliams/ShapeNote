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

    @NSManaged var date: NSDate
    @NSManaged var leader: Singer
    @NSManaged var song: Song
    @NSManaged var minutes: Minutes
    
    func twitterString() -> String {
        return leader.name + " led " + song.number + " " + song.title + "."
    }
}
