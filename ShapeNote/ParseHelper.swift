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
        // then get all groups nearby / sort
        
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

        // reload from server
        refreshSingersForSelectedGroup(completion)
    }
    
    func saveNewLocalSinger(singer:Singer) {
        
        let pfSinger = PFObject(className: "Singer")
        pfSinger["firstName"] = singer.firstName
        pfSinger["lastName"] = singer.lastName
        if let displayName = singer.displayName { pfSinger["displayName"] = displayName }
        // TODO etc with voicetype
        
        guard let user = PFUser.currentUser(),
            let singer = user["Singer"] as? PFObject else {
                fatalError()
        }
        
        singer.fetchIfNeededInBackgroundWithBlock({ (pfSinger:PFObject?, error:NSError?) -> Void in
            guard let pfSinger = pfSinger,
            let localGroup = pfSinger["group"] where error == nil
                else { self.handleError(error); return }
            
            localGroup.fetchIfNeededInBackgroundWithBlock({ (pfGroup:PFObject?, error:NSError?) -> Void in
                guard let pfGroup = pfGroup where error == nil else { self.handleError(error); return }
                
                self.saveGroup(pfGroup, onSinger: singer)
            })
        })
    }
    
    func saveGroup(group:Group, onUser user:PFUser) {
        
        var singer = user[PFKey.singer.rawValue] as? PFObject
        if singer == nil {
            singer = PFObject(className: "Singer")
            if let firstName = user["firstName"] {
                singer!["firstName"] = firstName
            }
            if let lastName = user["lastName"] {
                singer!["lastName"] = lastName
            }
            user["Singer"] = singer!
        }
        
        if let singer = singer,
            let pfGroup = ParseHelper.sharedHelper.findPFGroupMatchingGroup(group) {
                saveGroup(pfGroup, onSinger: singer)
                
        } else {
            print("Error saving group onto singer object");
        }
    }
    
    func saveGroup(pfGroup:PFObject, onSinger singer:PFObject) {
        
        singer[PFKey.group.rawValue] = pfGroup
        singer.saveInBackgroundWithBlock({ (saved:Bool, error:NSError?) -> Void in
            
            guard let _ = singer.objectId where error == nil && saved == true else { return }
            
            let relation = pfGroup.relationForKey("singers")
            relation.addObject(singer)
            
            singer.saveInBackgroundWithBlock({ (saved:Bool, error:NSError?) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    TabBarManager.sharedManager.clearLoginTab()
                })
            })
        })
    }

    func refreshSingersForSelectedGroup(completion:RefreshCompletionBlock) {
        
        guard let user = PFUser.currentUser(),
            let singer = user["Singer"] as? PFObject else {
                completion(.Error)
                return
        }
        
        singer.fetchIfNeededInBackgroundWithBlock({ (singer:PFObject?, error:NSError?) -> Void in
            guard let singer = singer else { completion(.Error); return }
            self.finishRefreshWithFetchedSinger(singer, completion: completion)
        })
    }
    
    func finishRefreshWithFetchedSinger(singer:PFObject, completion:RefreshCompletionBlock) {
        
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
            if PFUser.currentUser() != nil && objects.count > 0 && !Defaults.badgedSingersTabOnce {
                TabBarManager.sharedManager.badgeSingersTab()
                Defaults.badgedSingersTabOnce = true
            }
        })
    }
    
    func handleError(error:NSError?) {
        
        print(error)
        // TODO
    }
}