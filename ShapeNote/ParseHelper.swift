//
//  ParseHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 20/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation
import Parse
import CoreData

enum RefreshCompletionAction {
    case NoNewUsersFound
    case NewUsersFound
    case NoGroupOnUser
    case Error
}

typealias CompletionBlock = (() -> ())
typealias RefreshCompletionBlock = (RefreshCompletionAction -> ())

class ParseHelper {
    
    class var sharedHelper : ParseHelper {
        struct Static {
            static let instance:ParseHelper = ParseHelper()
        }
        return Static.instance
    }
    
    var pfGroups:[PFObject]?
    var groups:[Group]?
    
    func refresh(completion:RefreshCompletionBlock) {
        
        // TODO Get location
        
        
        // Get all groups nearby
        
        // Store them somewhere so we can put them in the UI
        
        // Update the singers in the local group
        
        PFQuery(className: "Group").findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            guard let objects = objects where error == nil else {
                print(error)
                completion(.Error)
                return
            }
            
            let groups = CoreDataHelper.sharedHelper.groups()
            self.groups = groups
            self.pfGroups = objects
            
            for object in objects {
                
                var found = false
                for group in groups {
                    
                    if group.name == object["name"] as? String {
                        found = true
                    }
                }
                
                if !found {
                    
                    let newGroup = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: CoreDataHelper.managedContext) as! Group
                    newGroup.name = object["name"] as! String
                }
            }
            CoreDataHelper.sharedHelper.saveContext()
            self.refreshSingersForSelectedGroup(completion)
        }
    }
    
    func findPFGroupMatchingGroup(group:Group) -> PFObject? {
        
        guard let pfGroups = self.pfGroups else { return nil }
        for object in pfGroups {
            if group.name == object["name"] as? String {
                return object
            }
        }
        
        return nil
    }
    
    func didChangeGroup(completion:RefreshCompletionBlock) {
        
        // delete all local singers
        let fetchRequest = NSFetchRequest(entityName: "Singer")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try CoreDataHelper.sharedHelper.persistentStoreCoordinator!.executeRequest(deleteRequest, withContext: CoreDataHelper.managedContext)
        } catch let error as NSError {
            
            let alert = UIAlertController(title: "Internal Error", message: "Error switching groups. If you see strange things, please delete the app and reinstall." + error.localizedDescription, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }

        // reload from server
        refreshSingersForSelectedGroup(completion)
    }

    func refreshSingersForSelectedGroup(completion:RefreshCompletionBlock) {
        
        guard let user = PFUser.currentUser(),
            let singer = user["Singer"] as? PFObject else {
                completion(.Error)
                return
        }
        
        do {
            try singer.fetch()
        } catch let error {
            print(error)
        }
        guard let group = singer[PFKey.group.rawValue] as? PFObject else {
            completion(.NoGroupOnUser)
            return
        }
        
        let query = group.relationForKey("singers").query()
        query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
            
            guard let objects = objects where error == nil else {
                print(error)
                completion(.Error)
                return
            }
            
            let singers = CoreDataHelper.sharedHelper.singers()
            
            for object in objects {
                
                var found = false
                for singer in singers {
                    
                    if singer.firstName == object["firstName"] as? String && singer.lastName == object["lastName"] as? String {
                        found = true
                    }
                }
                
                if !found {
                    
                    let newSinger = NSEntityDescription.insertNewObjectForEntityForName("Singer", inManagedObjectContext: CoreDataHelper.managedContext) as! Singer
                    newSinger.firstName = object["firstName"] as? String
                    newSinger.lastName = object["lastName"] as? String
                }
            }
            CoreDataHelper.sharedHelper.saveContext()
            TabBarManager.sharedManager.badgeSingersTab()
        })
    }
}