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
    case NotSpecified = 0
    case Bass = 1
    case Tenor = 2
    case Treble = 3
    case Alto = 4
}

@objc(Singer)

class Singer: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var shortName: String?
    @NSManaged var voice: Int16
    @NSManaged var twitter: String?
    @NSManaged var facebook: String?
    @NSManaged var firstSingDate: NSTimeInterval
    @NSManaged var lastSingDate: NSTimeInterval
    @NSManaged var group: Group?
    @NSManaged var songs: Leading?
    @NSManaged var minutes: NSSet?
    
    var voiceType:String {
        
        let v:Voice = Voice(rawValue: voice)!
        
        switch v {
        case .Bass: return "Bass"
        case .Tenor: return "Tenor"
        case .Treble: return "Treble"
        case .Alto: return "Alto"
        case .NotSpecified: return ""
        }
        
    }
}
