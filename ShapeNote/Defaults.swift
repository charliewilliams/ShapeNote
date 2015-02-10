//
//  Defaults.swift
//  ShapeNote
//
//  Created by Charlie Williams on 09/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

let bookKey = "currentBook"
let groupKey = "currentGroup"

class Defaults: NSObject {
    
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
    
    class var currentGroupName:String {
        get {
        if let stored = NSUserDefaults.standardUserDefaults().objectForKey(groupKey) as? String {
            return stored
        } else {
            return "Bristol"
            }
        }
        set(groupName) {
            NSUserDefaults.standardUserDefaults().setObject(groupName, forKey: groupKey)
        }
    }
}
