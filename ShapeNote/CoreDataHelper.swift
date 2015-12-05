//
//  CoreDataHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

enum ManagedClass:String {
    case Singer = "Singer"
    case Book = "Book"
    case Song = "Song"
    case Group = "Group"
}

class CoreDataHelper {

    class var sharedHelper : CoreDataHelper {
        struct Static {
            static let instance:CoreDataHelper = CoreDataHelper()
        }
        return Static.instance
    }
    
    var currentlySelectedGroup:Group? {
        get {
            return groupWithName(Defaults.currentGroupName)
        }
    }
    
    var currentlySelectedBook:Book {
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
    
    func singers(inGroup group:Group) -> [Singer]? {
        if let results = resultsForEntityName(ManagedClass.Singer.rawValue, matchingObject: group, inQueryString: "group == %@") as? [Singer] where results.count > 0 {
            return results.sort({ (a:Singer, b:Singer) -> Bool in
                return a.lastName > b.lastName
            })
        }
        
        // If there are no singers here we have a problem
        ParseHelper.sharedHelper.refreshSingersForSelectedGroup { (result:RefreshCompletionAction) -> () in
            ParseHelper.sharedHelper.didChangeGroup({ (result:RefreshCompletionAction) -> () in
                
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
    
    func book(title:String) -> Book? {
        return singleResultForEntityName(ManagedClass.Book.rawValue, matchingObject: title, inQueryString: "title == %@") as! Book?
    }
    
    func songs() -> [Song] {
        return songs(currentlySelectedBook.title)
    }
    
    func songs(inBook book:Book) -> [Song] {
        let results = resultsForEntityName(ManagedClass.Song.rawValue, matchingObject: book, inQueryString: "book == %@") as! [Song]
        return results.sort({ (a:Song, b:Song) -> Bool in
            return a.compare(b)
        })
    }
    
    func songs(inBookTitle:String) -> [Song] {
        let bookObject = book(inBookTitle)!
        return songs(inBook: bookObject)
    }
    
    func groups() -> [Group] {
        return resultsForEntityName(ManagedClass.Group.rawValue) as! [Group]
    }
    
    func groupWithName(name:String?) -> Group? {
        
        guard let name = name else { return nil }
        
        let fetchRequest = NSFetchRequest(entityName: ManagedClass.Group.rawValue)
        
        let resultPredicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
        fetchRequest.predicate = resultPredicate
        
        var group: Group? = nil
        
        do {
            let fetchedResults = try managedObjectContext!.executeFetchRequest(fetchRequest)
            group = fetchedResults.first as? Group
        } catch {
            return nil
        }
        
        return group
    }
    
    func minutes(group:Group) -> [Minutes]? {
        return resultsForEntityName("Minutes", matchingObject: nil, inQueryString: nil) as! [Minutes]?
    }
    
    func singleResultForEntityName(entityName:String, matchingObject object:NSObject?, inQueryString queryString:String?) -> NSManagedObject? {
        return resultsForEntityName(entityName, matchingObject: object, inQueryString: queryString)?.first
    }
    
    func resultsForEntityName(entityName:String, matchingObject object:NSObject?, inQueryString queryString:String?) -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest(entityName:entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        if queryString != nil {
            
            assert(object != nil, "Object is required when using a query string")
            
            let resultPredicate = NSPredicate(format: queryString!, object!)
            fetchRequest.predicate = resultPredicate
        }
        
        do {
            return try managedObjectContext!.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch {
            return nil
        }
    }
    
    func resultsForEntityName(entityName:String) -> [NSManagedObject]? {
        return resultsForEntityName(entityName, matchingObject: nil, inQueryString: nil)
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.charliewilliams.ShapeNote" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: self.modelURL)!
    }()
    
    lazy var modelURL:NSURL = {
        return NSBundle.mainBundle().URLForResource("ShapeNote", withExtension: "momd")!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ShapeNote.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let options = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
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
            CoreDataHelper.sharedHelper.handleError(error)
            
        } catch {
            
            CoreDataHelper.sharedHelper.handleError(nil)
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext where moc.hasChanges {
            
            print("Managed Object Count: \(moc.registeredObjects.count)")
            
            do {
                try moc.save()
//                moc.reset()
                
            } catch let error as NSError {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error.userInfo)")
                //                    abort()
                
                // The next most nuclear thing after just abort() is:
                deleteLocalDatabaseFile()
                moc.reset()
            }
        }
    }
    
    func deleteLocalDatabaseFile() {
        try! NSFileManager.defaultManager().removeItemAtURL(self.modelURL)
    }
    
    func handleError(error:NSError?) {
        
        var message = "Please email Charlie a description of what just happened so he can fix it.\n\nThis problem might also be fixed by deleting and reinstalling the app. (Sorry.)"
        if let error = error
            where error.localizedDescription.characters.count > 4 {
                message = error.localizedDescription
        }
        let alert = UIAlertController(title: "Core Data Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
}