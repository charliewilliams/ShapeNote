//
//  CoreDataHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum ManagedClass:String {
    case Singer = "Singer"
    case Book = "Book"
    case Song = "Song"
    case Group = "Group"
}

class CoreDataHelper {

    class var sharedHelper: CoreDataHelper {
        struct Static {
            static let instance = CoreDataHelper()
        }
        return Static.instance
    }
    
    var currentlySelectedGroup: Group? {
        get {
            return groupWithName(Defaults.currentGroupName)
        }
    }
    
    var currentlySelectedBook: Book {
        get {
            return book(Defaults.currentlySelectedBookTitle)!
        }
    }
    
    var currentSinger: Singer?
    
    func singersInCurrentGroup() -> [Singer]? {
        if let group = currentlySelectedGroup {
            return singers(inGroup: group)
        }
        return nil
    }
    
    func singers(inGroup group: Group) -> [Singer]? {
        if let results = resultsForEntityName(ManagedClass.Singer.rawValue, matchingObject: group, inQueryString: "group == %@") as? [Singer],
            results.count > 0 {
            return results.sorted(by: { (a:Singer, b:Singer) -> Bool in
                return a.lastName > b.lastName
            })
        }
        
        return nil
    }
    
    func singers() -> [Singer] {
        return resultsForEntityName(ManagedClass.Singer.rawValue) as! [Singer]
    }
    
    func books() -> [Book] {
        return resultsForEntityName(ManagedClass.Book.rawValue) as! [Book]
    }
    
    func book(_ title: String) -> Book? {
        return singleResultForEntityName(ManagedClass.Book.rawValue, matchingObject: title as NSObject?, inQueryString: "title == %@") as! Book?
    }
    
    func songs() -> [Song] {
        return songs(currentlySelectedBook.title)
    }
    
    func songs(inBook book: Book) -> [Song] {
        return resultsForEntityName(ManagedClass.Song.rawValue, matchingObject: book, inQueryString: "book == %@") as! [Song]
    }
    
    func songs(inBook bookId: BookIdentifier) -> [Song] {
        let bookObject = book(bookId.rawValue)!
        return songs(inBook: bookObject)
    }
    
    func songs(_ inBookTitle: String) -> [Song] {
        let bookObject = book(inBookTitle)!
        return songs(inBook: bookObject)
    }
    
    func fastUnsortedSongs() -> [Song] {
        return resultsForEntityName(ManagedClass.Song.rawValue, matchingObject: currentlySelectedBook, inQueryString: "book == %@") as! [Song]
    }
    
    func allSongsInAllBooks() -> [Song] {
        return resultsForEntityName(ManagedClass.Song.rawValue) as! [Song]
    }
    
    var numberOfSongsInCurrentBook: Int {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedClass.Song.rawValue)
        fetchRequest.predicate = NSPredicate(format: "book == %@", currentlySelectedBook)
        if let count = ((try? managedObjectContext?.count(for: fetchRequest)) as Int??) {
            return count ?? 0
        }
        return 0
    }
    
    func groups() -> [Group] {
        return resultsForEntityName(ManagedClass.Group.rawValue) as! [Group]
    }
    
    func groupWithName(_ name: String?) -> Group! {
        
        guard let name = name else { return nil }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedClass.Group.rawValue)
        
        let resultPredicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
        fetchRequest.predicate = resultPredicate
        
        do {
            let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
            if let group = fetchedResults.first as? Group {
                return group
            }
        } catch {
            return Group(name: name)
        }
        
        return Group(name: name)
    }
    
    func singleResultForEntityName(_ entityName:String, matchingObject object:NSObject?, inQueryString queryString:String?) -> NSManagedObject? {
        return resultsForEntityName(entityName, matchingObject: object, inQueryString: queryString)?.first
    }
    
    func resultsForEntityName(_ entityName:String, matchingObject object:NSObject?, inQueryString queryString:String?) -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        if queryString != nil {
            
            assert(object != nil, "Object is required when using a query string")
            
            let resultPredicate = NSPredicate(format: queryString!, object!)
            fetchRequest.predicate = resultPredicate
        }
        
        do {
            return try managedObjectContext!.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            return nil
        }
    }
    
    func resultsForEntityName(_ entityName:String) -> [NSManagedObject]? {
        return resultsForEntityName(entityName, matchingObject: nil, inQueryString: nil)
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.charliewilliams.ShapeNote" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf: self.modelURL)!
    }()
    
    lazy var modelURL: URL = {
        return Bundle.main.url(forResource: "ShapeNote", withExtension: "momd")!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("ShapeNote.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let options = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
        
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch let error as NSError {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error.userInfo)")
            CoreDataHelper.sharedHelper.deleteLocalDatabaseFile()
            ErrorHandler.handleError(error)
            
        } catch {
            
            ErrorHandler.handleError(nil)
            fatalError()
        }
        
        return coordinator
    }()
    
    class var managedContext: NSManagedObjectContext {
        return CoreDataHelper.sharedHelper.managedObjectContext!
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        guard let coordinator = self.persistentStoreCoordinator else {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if let moc = self.managedObjectContext, moc.hasChanges {

            do {
                try moc.save()
                
            } catch let error as NSError {

                NSLog("Unresolved error \(error), \(error.userInfo)")
                // abort()
                
                // The next most nuclear thing after just abort() is:
                deleteLocalDatabaseFile()
                moc.reset()
            }
        }
    }
    
    func deleteLocalDatabaseFile() {
        try! FileManager.default.removeItem(at: self.modelURL)
    }
}
