//
//  Singer.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

enum Voice:Int16 {
    case Bass = 0
    case Tenor = 1
    case Treble = 2
    case Alto = 3
}

@objc(Singer)

class Singer: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var shortName: String
    @NSManaged var voice: Int16
    @NSManaged var twitter: String
    @NSManaged var facebook: String
    @NSManaged var firstSingDate: NSTimeInterval
    @NSManaged var lastSingDate: NSTimeInterval
    @NSManaged var group: Group
    @NSManaged var songs: Leading
    
    var voiceType:String {
        
        let v:Voice = Voice(rawValue: voice)!
        
        switch v {
        case .Bass: return "Bass"
        case .Tenor: return "Tenor"
        case .Treble: return "Treble"
        case .Alto: return "Alto"
        }
        
    }
}
