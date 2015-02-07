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
        
        var userString: String;
        
        if leader.twitter.utf16Count > 0 {
            
            userString = "." + leader.twitter + " just led "
            
        } else {
            
            userString = leader.name + " led "
        }
        
        return userString + song.number + " " + song.title + "."
    }
}
