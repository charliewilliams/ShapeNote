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
            static let instance:CoreDataHelper = CoreDataHelper()
        }
        return Static.instance
    }
    
    var currentlySelectedGroup:Group {
        get {
            return groupWithName(Defaults.currentGroupName)!
        }
    }
    
    var currentlySelectedBook:Book {
        get {
            return book(Defaults.currentlySelectedBookTitle)!
        }
    }
    
    var currentSinger: Singer?
    
    func singers() -> [Singer] {
        return resultsForEntityName("Singer") as! [Singer]
    }
    
    func books() -> [Book] {
        return resultsForEntityName("Book") as! [Book]
    }
    
    func book(title:String) -> Book? {
        return singleResultForEntityName("Book", matchingObject: title, inQueryString: "title == %@") as! Book?
    }
    
    func songs() -> [Song] {
        return songs(currentlySelectedBook.title)
    }
    
    func songs(inBook:Book) -> [Song] {
         return resultsForEntityName("Song", matchingObject: inBook, inQueryString: "book == %@") as! [Song]
    }
    
    func songs(inBookTitle:String) -> [Song] {
        let bookObject = book(inBookTitle)!
        return songs(bookObject)
    }
    
//    func fetchedResultsControllerForClassName(className:String, matchingObject object:NSObject?, inQueryString queryString:String?) -> NSFetchedResultsController {
//        
//        let fetchRequest = NSFetchRequest(entityName:className)
//        var error: NSError?
//        let entityDescription = NSEntityDescription.entityForName(className, inManagedObjectContext: managedObjectContext!)
//        fetchRequest.entity = entityDescription
//        
//        let sort = NSSortDescriptor(key: "date", ascending: false)
//        
////        , compare: { (date1:NSDate, date2:NSDate) -> NSComparisonResult in
////            return date1.timeIntervalSince1970 > date2.timeIntervalSince1970
////        })
////        
//        fetchRequest.sortDescriptors = [sort]
//        
//        fetchRequest.fetchBatchSize = 30
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Root")
//        
//        return fetchedResultsController
//    }
    
    func groups() -> [Group] {
        
        return resultsForEntityName("Group") as! [Group]
    }
    
    func groupWithName(name:String) -> Group? {
        
        let fetchRequest = NSFetchRequest(entityName: "Group")
        
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
        
        print("\(group) \(group.name)")
        return resultsForEntityName("Minutes", matchingObject: nil, inQueryString: nil) as! [Minutes]?
        // WARNING: Why doesn't this work?
//        return resultsForEntityName("Minutes", matchingObject: group, inQueryString: "group == %@") as [Minutes]?
    }
    
    func singleResultForEntityName(entityName:String, matchingObject object:NSObject?, inQueryString queryString:String?) -> AnyObject? {
        return resultsForEntityName(entityName, matchingObject: object, inQueryString: queryString)?.first
    }
    
    func resultsForEntityName(entityName:String, matchingObject object:NSObject?, inQueryString queryString:String?) -> [AnyObject]? {
        
        let fetchRequest = NSFetchRequest(entityName:entityName)
        fetchRequest.returnsObjectsAsFaults = false
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        if queryString != nil {
            
            assert(object != nil, "Object is required when using a query string")
            
            let resultPredicate = NSPredicate(format: queryString!, object!)
            fetchRequest.predicate = resultPredicate
        }
        
        var results: [AnyObject]? = nil
        
        do {
            let fetchedResults = try managedObjectContext!.executeFetchRequest(fetchRequest)
            results = fetchedResults as? [NSManagedObject]
        } catch {
            return nil
        }
        
        return results
    }
    
    func resultsForEntityName(entityName:String) -> [NSManagedObject] {
        return resultsForEntityName(entityName, matchingObject: nil, inQueryString: nil) as! [NSManagedObject]
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.charliewilliams.ShapeNote" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
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
        
        let options = [NSMigratePersistentStoresAutomaticallyOption:true,
            NSInferMappingModelAutomaticallyOption:true
        ]
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    class var managedContext: NSManagedObjectContext {
        return CoreDataHelper.sharedHelper.managedObjectContext!
    }
    
//    class func save() {
//        var error:NSError?
//        CoreDataHelper.sharedHelper.managedObjectContext?.save(&error)
//        if (error != nil) {
//            print("CORE DATA ERROR: \(error)")
//        }
//    }
    
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
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}