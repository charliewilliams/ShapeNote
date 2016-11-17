//
//  Defaults.swift
//  ShapeNote
//
//  Created by Charlie Williams on 09/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

let firstRunKey = "firstRunHappened"
let loggedInOnce = "loggedInOnce"
let hasBadgedSingersTabOnce = "badgedSingersTabOnce"
let bookKey = "currentBook"
let groupKey = "currentGroup"
let twitterKey = "hasTwitter"

class Defaults: NSObject {
    
    class var isFirstRun:Bool {
        get {
            return !UserDefaults.standard.bool(forKey: firstRunKey)
        }
        set(newValue) {
            UserDefaults.standard.set(true, forKey: firstRunKey)
        }
    }
    
    class var neverLoggedIn:Bool {
        get {
            return !UserDefaults.standard.bool(forKey: loggedInOnce)
        }
        set(newValue) {
            UserDefaults.standard.set(true, forKey: loggedInOnce)
        }
    }
    
    class var badgedSingersTabOnce:Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasBadgedSingersTabOnce)
        }
        set(newValue) {
            UserDefaults.standard.set(true, forKey: hasBadgedSingersTabOnce)
        }
    }
    
    class var currentlySelectedBookTitle:String {
        get {
            if let stored = UserDefaults.standard.object(forKey: bookKey) as? String {
                return stored
            } else {
                return BookIdentifier.sacredHarp.rawValue
            }
        }
        set(booktitle) {
            UserDefaults.standard.set(booktitle, forKey: bookKey)
        }
    }
    
    class var currentGroupName:String? {
        get {
            return UserDefaults.standard.object(forKey: groupKey) as? String
        }
        set(groupName) {
            UserDefaults.standard.set(groupName, forKey: groupKey)
        }
    }
    
    class var hasTwitter: Bool {
        get {
            return UserDefaults.standard.bool(forKey: twitterKey)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: twitterKey)
        }
    }
}
