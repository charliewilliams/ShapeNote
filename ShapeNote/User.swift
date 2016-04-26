//
//  User.swift
//  ShapeNote
//
//  Created by Charlie Williams on 25/04/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit
import Parse

class User: PFUser {

    private enum UserFields: String {
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case username = "username"
    }
    
    var firstName: String! {
        get {
            return self[UserFields.firstName.rawValue] as? String
        }
        set(newValue) {
            self[UserFields.firstName.rawValue] = newValue
        }
    }
    
    var lastName: String! {
        get {
            return self[UserFields.lastName.rawValue] as? String
        }
        set(newValue) {
            self[UserFields.lastName.rawValue] = newValue
        }
    }
    
    var displayName: String {
        return firstName + " " + lastName
    }
    
    var associatedSinger: Singer! {
        get {
            return self[PFKey.associatedSingerObject.rawValue] as? Singer
        }
        set(newValue) {
            if let newValue = newValue {
                self[PFKey.associatedSingerObject.rawValue] = newValue
            } else {
                self.removeObjectForKey(PFKey.associatedSingerObject.rawValue)
            }
        }
    }
}
