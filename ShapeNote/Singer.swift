//
//  Singer.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData
import SwiftSpinner

enum Voice: String {
    case NotSpecified = ""
    case Bass = "Bass"
    case Tenor = "Tenor"
    case Treble = "Treble"
    case Alto = "Alto"
}

func ==(lhs: Singer, rhs: Singer) -> Bool {
    return lhs.facebookId == rhs.facebookId
}

@objc(Singer)

class Singer: NSManagedObject {
    
    @NSManaged var displayName: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var voice: String?
    @NSManaged var twitter: String?
    @NSManaged var facebookId: String?
    @NSManaged var firstSingDate: NSTimeInterval
    @NSManaged var lastSingDate: NSTimeInterval
    @NSManaged var group: Group?
    @NSManaged var songs: Lesson?
    @NSManaged var minutes: NSSet?
    
    var name:String {
        return displayName ?? firstName ?? ""
    }
    
    var networkObject: PFObject?
    
    func buildPFObject() -> PFObject {
        
        let object = networkObject ?? PFObject(className: PFClass.Singer.rawValue)
        object[PFKey.firstName.rawValue] = firstName
        object[PFKey.lastName.rawValue] = lastName
        if let displayName = displayName {
            object[PFKey.displayName.rawValue] = displayName
        }
        if let voice = voice {
            object[PFKey.voiceType.rawValue] = voice
        }
        if let twitter = twitter {
            object[PFKey.twitter.rawValue] = twitter
        }
        if let facebookId = facebookId {
            object[PFKey.facebookId.rawValue] = facebookId
        }
        object[PFKey.firstSing.rawValue] = firstSingDate
        object[PFKey.lastSing.rawValue] = lastSingDate
        
        if let facebookGroupId = group?.facebookID {
            object[PFKey.facebookGroupId.rawValue] = facebookGroupId
        }
        
        // TODO save all groups + minutes?
        
        self.networkObject = object
        return object
    }
    
    func saveToCloud(completion: PFBooleanResultBlock) {
        
        networkObject = buildPFObject()
        networkObject?.saveInBackgroundWithBlock { (success, error) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                SwiftSpinner.hide()
                TabBarManager.sharedManager.clearLoginTab()
                completion(success, error)
            }
        }
    }
    
    func fetchFromCloud(completion: PFObjectResultBlock) {
        precondition(facebookId != nil)
        
        let query = PFQuery(className: PFClass.Singer.rawValue)
        query.whereKey(PFKey.facebookId.rawValue, equalTo: facebookId!)
        
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            
            self.networkObject = object ?? PFObject(className: PFClass.Singer.rawValue)
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                completion(object, error)
            }
        }
    }
    
    private func handleError(error: NSError?) {
        
        //
    }
}
