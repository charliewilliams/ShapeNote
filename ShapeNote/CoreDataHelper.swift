//
//  CoreDataHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHelper {

    class var sharedHelper : CoreDataHelper {
        struct Static {
            static let instance : CoreDataHelper = CoreDataHelper()
        }
        return Static.instance
    }
    
    func singers() -> [Singer] {
        
        return resultsForEntityName("Singer") as [Singer]
    }
    
    func books() -> [Book] {
        
        return resultsForEntityName("Book") as [Book]
    }
    
    func songs(book:String?) -> [Song] {
        
        return resultsForEntityName("Song") as [Song]
    }
    
    func groups() -> [Group] {
        
        return resultsForEntityName("Group") as [Group]
    }
    
    func groupWithName(name:String) -> Group? {
        
        let fetchRequest = NSFetchRequest(entityName: "Group")
        var error: NSError?
        
        let resultPredicate = NSPredicate(format: "name = %@", name)
        fetchRequest.predicate = resultPredicate
        
        let fetchedResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as [Group]
        
        if error != nil {
            println("error loading results for Group: \(error)")
        }
        
        return fetchedResults.first
    }
    
    func minutes(groupName:String) -> [Minutes]? {
        
        let fetchRequest = NSFetchRequest(entityName: "Minutes")
        var error: NSError?
        
        let resultPredicate = NSPredicate(format: "name = %@", groupName)
        fetchRequest.predicate = resultPredicate
        
        let fetchedResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as [Minutes]
        
        if error != nil {
            println("error loading results for Minutes: \(error)")
        }
        
        return fetchedResults
    }
    
    func resultsForEntityName(entityName:String) -> [NSManagedObject] {
        
        let fetchRequest = NSFetchRequest(entityName:entityName)
        var error: NSError?
        
        let fetchedResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]
        
        if error != nil {
            println("error loading results for \(entityName): \(error)")
        }
        
        return fetchedResults
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.charliewilliams.ShapeNote" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {

        let modelURL = NSBundle.mainBundle().URLForResource("ShapeNote", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ShapeNote.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "com.charliewilliams", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    class var managedContext: NSManagedObjectContext? {
        return CoreDataHelper.sharedHelper.managedObjectContext
    }
    
    class func save() {
        var error:NSError?
        CoreDataHelper.sharedHelper.managedObjectContext?.save(&error)
        if (error != nil) {
            println("CORE DATA ERROR: \(error)")
        }
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}