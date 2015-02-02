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
        
        let songs = CoreDataHelper.sharedHelper.songs(nil) as [NSManagedObject]?
        
        if (songs?.count > 0) {
            return
        }
        
        let book = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: coreDataContext()) as Book
        book.title = "The Sacred Harp (1991)"
        book.year = "1991";
        book.author = "Sacred Harp Publishing Company"
        
        let groupNames = ["Bristol", "London", "Cork", "Norwich", "Manchester", "Amsterdam", "Poland", "Dublin", "Boston"]
        
        for name in groupNames {
            let group = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: coreDataContext()) as Group
            group.name = name
        }
        
        let charlie = NSEntityDescription.insertNewObjectForEntityForName("Singer", inManagedObjectContext: coreDataContext()) as Singer
        charlie.name = "Charlie Williams"
        charlie.shortName = "Charlie"
        charlie.twitter = "buildsucceeded"
        charlie.facebook = "Yes"
        charlie.voice = Voice.Tenor.rawValue
        
        let emma = NSEntityDescription.insertNewObjectForEntityForName("Singer", inManagedObjectContext: coreDataContext()) as Singer
        emma.name = "Emma Hooper"
        emma.shortName = "Emma"
        emma.twitter = "waitress4thbees"
        emma.facebook = "Yes"
        emma.voice = Voice.Alto.rawValue
        if let bristol = CoreDataHelper.sharedHelper.groupWithName("Bristol") {
            charlie.group = bristol
            emma.group = bristol
        }
        
        var songsSet = NSMutableOrderedSet();

        let json = loadFilesFromBundle()
        
        for d:NSDictionary in json {
            
            let s = NSEntityDescription.insertNewObjectForEntityForName("Song", inManagedObjectContext: coreDataContext()) as Song
            s.configureWithDict(d)
            songsSet.addObject(s)
        }
        
        book.songs = songsSet
        
        var error:NSError?
        coreDataContext().save(&error)
        if error != nil {
            println(error)
        }
    }

    func loadFilesFromBundle() -> [NSDictionary] {
        
        let songsPath = NSBundle.mainBundle().pathForResource("SH1991", ofType: "json")?
        
        if songsPath == nil {
            println("Missing songs file in bundle!")
            abort()
        }
        let data = NSFileManager.defaultManager().contentsAtPath(songsPath!)
        assert(data != nil, "Need data")
        var jsonError: NSError?
        
        var decodedJson = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers, error: &jsonError) as NSArray
        if jsonError != nil {
            println(jsonError)
        }
        
        return decodedJson as [NSDictionary]
    }

    func coreDataContext() -> NSManagedObjectContext! {
        
        return CoreDataHelper.managedContext
    }
}
