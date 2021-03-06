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
        
        // If we have data, don't reload from JSON
        if let _ = CoreDataHelper.sharedHelper.book(BookIdentifier.sacredHarp.rawValue) {
            return
        }
        
        let shBookDef = ["title":BookIdentifier.sacredHarp.rawValue,
                         "shortTitle": "Sacred Harp",
                         "fileName":"SH1991",
                         "year":"1991",
                         "author":"The Sacred Harp Publishing Company",
                         "hashTag":"#SacredHarp",
                         "default":"true"]
        
        let chBookDef = ["title":BookIdentifier.christianHarmony.rawValue,
                         "shortTitle": "Christian Harmony",
                         "fileName":"CH",
                         "year":"2010",
                         "author":"Christian Harmony",
                         "hashTag":"#7Shapes"]
        
        let shenBookDef = ["title":BookIdentifier.shenandoah.rawValue,
                           "shortTitle": "Shenandoah",
                           "fileName":"Shenandoah",
                           "year":"2012",
                           "author":"The Shenandoah Harmony Publishing Company",
                           "hashTag":"#Shenandoah"]
        
        let coopBookDef = ["title":BookIdentifier.cooper.rawValue,
                           "shortTitle": "Cooper Book",
                           "fileName":"Cooper2012",
                           "year":"2012",
                           "author":"The Sacred Harp Book Company",
                           "hashTag":"#CooperBook"]
        
        let bookDefs = [shBookDef, chBookDef, shenBookDef, coopBookDef]
        
        for bookDef in bookDefs {
            
            // make the book
            let book = NSEntityDescription.insertNewObject(forEntityName: "Book", into: coreDataContext()) as! Book
            book.title = bookDef["title"]!
            book.shortTitle = bookDef["shortTitle"]!
            book.year = bookDef["year"]!
            book.author = bookDef["author"]!
            book.hashTag = bookDef["hashTag"]!
            
            // load the songs
            let songsSet = NSMutableOrderedSet()
            let json = loadFileFromBundle(bookDef["fileName"]!)
            
            for dict in json {
                
                let song = Song(book: book)
                song.configureWithDict(dict)
                songsSet.add(song)
            }
            
            book.songs = songsSet
        }
        
        do {
            try coreDataContext().save()
        } catch let error as NSError {
            print("\(error)")
        }
    }

    func loadFileFromBundle(_ fileName:String) -> [NSDictionary] {
        
        guard let songsPath = Bundle.main.path(forResource: fileName, ofType: "json"),
            let data = FileManager.default.contents(atPath: songsPath)
            else {
                print("Couldn't read required file in bundle")
                abort()
        }
        
        let decodedJson: AnyObject = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
        guard let json = decodedJson as? [NSDictionary]
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
