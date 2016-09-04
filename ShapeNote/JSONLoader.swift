//
//  JSONLoader.swift
//  ShapeNotes
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

let sacredHarpTitle = "The Sacred Harp (1991)"

class JSONLoader: NSObject {
    
    class var sharedLoader : JSONLoader {
        struct Static {
            static let instance : JSONLoader = JSONLoader()
        }
        return Static.instance
    }
    
    func handleFirstRun() {
        
        // If we have data, don't reload from JSON
        if let _ = CoreDataHelper.sharedHelper.book(sacredHarpTitle) {
            return
        }
        
        let shBookDef = ["title":sacredHarpTitle,
            "fileName":"SH1991",
            "year":"1991",
            "author":"The Sacred Harp Publishing Company",
            "hashTag":"#SacredHarp",
            "default":"true"]
        
        let chBookDef = ["title":"The Christian Harmony (2010)",
            "fileName":"CH",
            "year":"2010",
            "author":"Christian Harmony",
            "hashTag":"#7Shapes"]
        
        let shenBookDef = ["title":"The Shenandoah Harmony (2012)",
            "fileName":"Shenandoah",
            "year":"2012",
            "author":"The Shenandoah Harmony Publishing Company",
            "hashTag":"#Shenandoah"]
        
        let coopBookDef = ["title":"The Sacred Harp (Cooper, 2012)",
            "fileName":"Cooper2012",
            "year":"2012",
            "author":"The Sacred Harp Book Company",
            "hashTag":"#CooperEdition"]
        
        let bookDefs = [shBookDef, chBookDef, shenBookDef, coopBookDef]
        
        for bookDef in bookDefs {
            
            // make the book
            let book = NSEntityDescription.insertNewObject(forEntityName: "Book", into: coreDataContext()) as! Book
            book.title = bookDef["title"]!
            book.year = bookDef["year"]!
            book.author = bookDef["author"]!
            book.hashTag = bookDef["hashTag"]!
            
            // load the songs
            let songsSet = NSMutableOrderedSet();
            let json = loadFileFromBundle(bookDef["fileName"]!)
            
            for d:NSDictionary in json {
                
                let s = NSEntityDescription.insertNewObject(forEntityName: "Song", into: coreDataContext()) as! Song
                s.configureWithDict(d)
                songsSet.add(s)
            }
            
            book.songs = songsSet
        }
        
        var error:NSError?
        do {
            try coreDataContext().save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print(error)
        }
    }

    func loadFileFromBundle(_ fileName:String) -> [NSDictionary] {
        
        guard let songsPath = Bundle.main.path(forResource: fileName, ofType: "json"),
            let data = FileManager.default.contents(atPath: songsPath)
            else {
                print("Couldn't read required file in bundle")
                abort()
        }
        
        guard let decodedJson: AnyObject = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! AnyObject,
            let json = decodedJson as? [NSDictionary]
            else {
                print("Couldn't decode JSON in bundle")
                abort()
        }
    
        return json
    }

    func coreDataContext() -> NSManagedObjectContext {
        return CoreDataHelper.managedContext
    }
}
