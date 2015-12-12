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
import SwiftSpinner

enum RefreshCompletionAction {
    case NoNewUsersFound
    case NewUsersFound
    case NoGroupOnUser
    case NoLocalUser
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
        
        SwiftSpinner.show("Loading…", animated: true)
        
        let query = PFQuery(className: "Group")
        query.limit = 1000;
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            guard let objects = objects where error == nil else {
                SwiftSpinner.hide()
                completion(.Error)
                self.handleError(error)
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
    
    func saveNewLocalSinger(singer:Singer, completion:CompletionBlock) {
        
        let pfSinger = PFObject(className: PFKey.singer.rawValue)
        pfSinger["firstName"] = singer.firstName
        pfSinger["lastName"] = singer.lastName
        if let displayName = singer.displayName { pfSinger["displayName"] = displayName }
        // TODO etc with voicetype
        
        guard let user = PFUser.currentUser(),
            let singer = user[PFKey.singer.rawValue] as? PFObject else {
                fatalError()
        }
        
        singer.fetchIfNeededInBackgroundWithBlock({ (pfSinger:PFObject?, error:NSError?) -> Void in
            guard let pfSinger = pfSinger,
            let localGroup = pfSinger["group"] where error == nil
                else {
                    self.handleError(error)
                    return
            }
            
            localGroup.fetchIfNeededInBackgroundWithBlock({ (pfGroup:PFObject?, error:NSError?) -> Void in
                guard let pfGroup = pfGroup where error == nil else { self.handleError(error); return }
                
                self.saveGroup(pfGroup, onSinger: singer, completion: completion)
            })
        })
    }
    
    func saveGroup(group:Group, onUser user:PFUser, completion:CompletionBlock) {
        
        SwiftSpinner.show("Loading singers…", animated: true)
        Defaults.currentGroupName = group.name
        var singer = user[PFKey.singer.rawValue] as? PFObject
        
        // First, query for a singer with that name
        let query = PFQuery(className: PFKey.singer.rawValue)
        query.whereKey("fbID", equalTo: user["id"])
        query.findObjectsInBackgroundWithBlock { (results:[PFObject]?, error:NSError?) -> Void in
            
            if let error = error {
                self.handleError(error)
                return
            }
            
            if let results = results where results.count > 0 {
                
                user[PFKey.singer.rawValue] = results.first
            }
            
            if let firstName = user["firstName"],
                let lastName = user["lastName"] where singer == nil {
                    
                    // If there isn't one, make a new one
                    singer = PFObject(className: PFKey.singer.rawValue)
                    singer!["firstName"] = firstName
                    singer!["lastName"] = lastName
            }
            
            // Bah! Which of these is right?
            if let firstName = user["first_name"],
                let lastName = user["last_name"] where singer == nil {
                    singer = PFObject(className: PFKey.singer.rawValue)
                    singer!["firstName"] = firstName
                    singer!["lastName"] = lastName
            }
            
            if let singer = singer {
                user[PFKey.singer.rawValue] = singer
            }
            
            user.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let error = error {
                        self.handleError(error)
                        completion()
                        return
                    }
                    
                    self.finishSaveWithSinger(singer, group:group, completion:completion)
                })
            })
        }
    }
    
    func finishSaveWithSinger(singer:PFObject?, group:Group, completion:CompletionBlock) {
        
        if let singer = singer,
            let pfGroup = ParseHelper.sharedHelper.findPFGroupMatchingGroup(group) {
                saveGroup(pfGroup, onSinger: singer, completion: completion)
                
        } else {
            
            SwiftSpinner.hide()
            PFUser.logOut()
            FBSession.activeSession().closeAndClearTokenInformation()
            handleError("Error saving group onto singer object")
            completion()
        }
    }
    
    func saveGroup(pfGroup:PFObject, onSinger singer:PFObject, completion:CompletionBlock) {
        
        singer[PFKey.group.rawValue] = pfGroup
        singer.saveInBackgroundWithBlock({ (saved:Bool, error:NSError?) -> Void in
            
            guard let _ = singer.objectId where error == nil && saved == true else {
                self.handleError(error)
                completion()
                return
            }
            
            let relation = pfGroup.relationForKey("singers")
            relation.addObject(singer)
            
            singer.saveInBackgroundWithBlock({ (saved:Bool, error:NSError?) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SwiftSpinner.hide()
                    TabBarManager.sharedManager.clearLoginTab()
                    completion()
                })
            })
        })
    }

    func refreshSingersForSelectedGroup(completion:RefreshCompletionBlock) {
        
        guard let user = PFUser.currentUser(),
            let singer = user[PFKey.singer.rawValue] as? PFObject else {
                loadSingersForGroupByName(Defaults.currentGroupName, completion: completion)
                return
        }
        
        SwiftSpinner.show("Loading singers…", animated: true)
        singer.fetchIfNeededInBackgroundWithBlock({ (singer:PFObject?, error:NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in                
                guard let singer = singer else {
                    SwiftSpinner.hide()
                    if let error = error where error.code == PFErrorCode.ErrorObjectNotFound.rawValue {
                        self.loadSingersForGroupByName(Defaults.currentGroupName, completion: completion)
                        return
                    }
                    completion(.Error);
                    self.handleError(error);
                    return
                }
                self.finishRefreshWithFetchedSinger(singer, completion: completion)
            })
        })
    }
    
    func finishRefreshWithFetchedSinger(singer:PFObject, completion:RefreshCompletionBlock) {
        
        guard let group = singer[PFKey.group.rawValue] as? PFObject else {
            SwiftSpinner.hide()
            completion(.NoGroupOnUser)
//            handleError(nil)
            return
        }
        
        loadSingersForGroup(group, completion: completion)
    }
    
    func loadSingersForGroup(group:PFObject, completion:RefreshCompletionBlock) {
        
        let query = group.relationForKey("singers").query()
        query.limit = 1000;
        query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.gotSingersFromParse(objects, error: error, completion:completion)
            })
        })
    }
    
    func gotSingersFromParse(objects:[PFObject]?, error:NSError?, completion:RefreshCompletionBlock) {
        
        guard let objects = objects where error == nil else {
            SwiftSpinner.hide()
            completion(.Error)
            handleError(error)
            return
        }
        
        let singers = CoreDataHelper.sharedHelper.singers()
        let group = CoreDataHelper.sharedHelper.currentlySelectedGroup
        
        for object in objects {
            
            var found = false
            for singer in singers {
                
                if singer.facebook == object["fbID"] as? String {
                    found = true
                }
            }
            
            if !found {
                
                let newSinger = NSEntityDescription.insertNewObjectForEntityForName("Singer", inManagedObjectContext: CoreDataHelper.managedContext) as! Singer
                newSinger.firstName = object["firstName"] as? String
                newSinger.lastName = object["lastName"] as? String
                newSinger.facebook = object["fbID"] as? String
                newSinger.displayName = object["displayName"] as? String
                newSinger.group = group
            }
        }
        
        SwiftSpinner.hide()
        CoreDataHelper.sharedHelper.saveContext()
        if objects.count > 0 && !Defaults.badgedSingersTabOnce && !Defaults.neverLoggedIn {
            TabBarManager.sharedManager.badgeSingersTab()
        }
        
        completion(.NewUsersFound)
    }
    
    func loadSingersForGroupByName(name:String?, completion:RefreshCompletionBlock) {
        
        guard let name = name else {
            completion(.NoGroupOnUser)
            return
        }
        
        let query:PFQuery = PFQuery(className: ManagedClass.Group.rawValue)
        query.whereKey("name", equalTo: name)
        query.findObjectsInBackgroundWithBlock { (groups:[PFObject]?, error:NSError?) -> Void in
            
            guard let groups = groups,
                let group = groups.first where groups.count > 0 && error == nil else {
                self.handleError(error)
                completion(.Error)
                return
            }

            self.loadSingersForGroup(group, completion: completion)
        }
    }
    
    func handleError(error:NSError?) {
        
        var message = "There was an error talking to the cloud. That's all we know."
        if let error = error
            where error.localizedDescription.characters.count > 4 {
                message = error.localizedDescription
        }
        handleError(message)
    }
    
    func handleError(text:String) {
    
        let alert = UIAlertController(title: "Network Error", message: text, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        let tempWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        tempWindow.rootViewController = UIViewController()
        tempWindow.windowLevel = UIWindowLevelAlert + 1
        tempWindow.makeKeyAndVisible()
        tempWindow.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
}