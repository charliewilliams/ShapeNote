//
//  StoredValueCoordinator.swift
//  ShapeNote
//
//  Created by Charlie Williams on 18/12/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import Foundation

/*
 ["SacredHarp": ["49t":        ["fav":      true,  "notes":    "A nice one in 3"]]]
 ["BookName":   ["SongNumber": ["InfoType": value, "InfoType": value            ]]]
 */

typealias BookName = String
typealias SongNumber = String
typealias InfoType = String
typealias Value = String

typealias StoreType = [BookName: [SongNumber: [InfoType: Value]]]

protocol StoredValueCoordinator {
    
    // On first launch we possibly will do a blocking call to see if there are existing favorites somewhere out there
    var isFirstLaunch: Bool { get }
    
    func locallyStoredValues(coreDataHelper: CoreDataHelper) -> StoreType
    
//    func remoteStoredValues(completion: (_ success: Bool, _ values: StoreType) -> ())
//    func storeRemoteValue(value: StoreType, completion: (_ success: Bool) -> ())
}

extension StoredValueCoordinator {
    
    var isFirstLaunch: Bool {
        return Defaults.isFirstRun
    }
    
    func locallyStoredValues(coreDataHelper: CoreDataHelper) -> StoreType {
        
        var values = StoreType()
        
        for book in coreDataHelper.books() {

            var thisBook = values[book.title] ?? [:]
            
            songLoop: for song in Array(book.songs) as! [Song] {
                
                if !song.favorited && song.notes == nil {
                    continue songLoop
                }
                
                var thisSong = thisBook[song.number] ?? [:]
                
                if song.favorited {
                    thisSong["fav"] = "true"
                }
                if let notes = song.notes {
                    thisSong["notes"] = notes
                }
                
                thisBook[song.number] = thisSong
            }
            
            values[book.title] = thisBook
        }
        
        return values
    }
    
    
}

struct StoreCoordinator: StoredValueCoordinator {
    
}
