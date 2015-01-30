//
//  JSONLoader.swift
//  ShapeNotes
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

class JSONLoader: NSObject {
    
    class var sharedLoader : JSONLoader {
        struct Static {
            static let instance : JSONLoader = JSONLoader()
        }
        return Static.instance
    }
    
    func handleFirstRun() {
        
        if NSUserDefaults.standardUserDefaults().boolForKey("FirstRun") {
            return
        }
        
        let json = loadFilesFromBundle()
        
        for d:NSDictionary in json {
            
            let s: Song = Song()
            s.configureWithDict(d)
        }
    }

    func loadFilesFromBundle() -> [NSDictionary] {
        
        let songsPath = NSBundle.mainBundle().pathForResource("SH1991", ofType: "json")
        let data = NSFileManager.defaultManager().contentsAtPath(songsPath!)
        assert(data != nil, "Need data")
        var jsonError: NSError?
        
        var decodedJson = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers, error: &jsonError) as NSArray
        if jsonError != nil {
            println(jsonError)
        }
        print(decodedJson)
        
        return decodedJson as [NSDictionary]
    }

    func coreDataContext() -> NSManagedObjectContext! {
        
        return CoreDataHelper.sharedHelper.managedObjectContext
    }
}
