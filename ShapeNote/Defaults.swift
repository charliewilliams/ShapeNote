//
//  Defaults.swift
//  ShapeNote
//
//  Created by Charlie Williams on 09/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

let bookKey = "currentBook"

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
}
