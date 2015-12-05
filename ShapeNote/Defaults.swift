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

class Defaults: NSObject {
    
    class var isFirstRun:Bool {
        get {
            return !NSUserDefaults.standardUserDefaults().boolForKey(firstRunKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: firstRunKey)
        }
    }
    
    class var neverLoggedIn:Bool {
        get {
            return !NSUserDefaults.standardUserDefaults().boolForKey(loggedInOnce)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: loggedInOnce)
        }
    }
    
    class var badgedSingersTabOnce:Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(hasBadgedSingersTabOnce)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: hasBadgedSingersTabOnce)
        }
    }
    
    class var currentlySelectedBookTitle:String {
        get {
            if let stored = NSUserDefaults.standardUserDefaults().objectForKey(bookKey) as? String {
                return stored
            } else {
                return "The Sacred Harp (1991)"
            }
        }
        set(booktitle) {
            NSUserDefaults.standardUserDefaults().setObject(booktitle, forKey: bookKey)
        }
    }
    
    class var currentGroupName:String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(groupKey) as? String
        }
        set(groupName) {
            NSUserDefaults.standardUserDefaults().setObject(groupName, forKey: groupKey)
        }
    }
}
