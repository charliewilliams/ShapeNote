//
//  GroupsPickerViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 06/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

enum PFClass:String {
    case LocalSinging = "LocalSinging"
}

enum PFKey:String {
    case name = "name"
    case fbGroupID = "fbGroupID"
}

class GroupsPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var groups:[NSDictionary]? {
        didSet {
            if let groups = groups where groups.count > 0 {
                checkGroupsAgainstExistingOnServer(groups)
            }
        }
    }
    var filtering = true
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var showAllGroupsButton: UIBarButtonItem!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        guard let groups = groups else { return 0 }
        
        if filtering {
            if let filteredGroups = filteredGroups
            where filteredGroups.count > 0 {
                return filteredGroups.count
            }
        }
        
        return groups.count
    }
    
    var filteredGroups:[NSDictionary]? {
        return groups?.filter({ (element:NSDictionary) -> Bool in
            if element["name"]?.containsString("Sacred") == true {
                return true
            }
            if element["name"]?.containsString("Harp") == true {
                return true
            }
            if element["name"]?.containsString("Shapenote") == true {
                return true
            }
            if element["name"]?.containsString("Shape note") == true {
                return true
            }
            
            return false
        })
    }
    
    func checkGroupsAgainstExistingOnServer(newGroups:[NSDictionary]) {
        
        PFQuery(className: PFClass.LocalSinging.rawValue).findObjectsInBackgroundWithBlock { [weak self] (results:[PFObject]?, error:NSError?) -> Void in
            
            guard let results = results where error == nil  else { self?.handleError(error); return }
            
            let unknownGroups = newGroups.filter({ (group:NSDictionary) -> Bool in
                
                for result in results {
                    if let storedGroupID = result[PFKey.fbGroupID.rawValue] as? String,
                        let newGroupID = group["id"] as? String
                        where storedGroupID == newGroupID {
                        return true
                    }
                }
                return false
            })
            
            print(unknownGroups)
            
            var newGroupObjects = [PFObject]()
            for newGroup in unknownGroups {
                
                let newGroupObject = PFObject(className: PFClass.LocalSinging.rawValue)
                newGroupObject[PFKey.fbGroupID.rawValue] = newGroup["id"]
                newGroupObject[PFKey.name.rawValue] = newGroup["name"]
                newGroupObjects.append(newGroupObject)
            }
            
            PFObject.saveAllInBackground(newGroupObjects, block: { (success:Bool, error:NSError?) -> Void in
                self?.pickerView.reloadComponent(0)
            })
        }
    }
    
    @IBAction func showAllGroupsPressed(sender: AnyObject) {
        self.filtering = !self.filtering
        self.pickerView.reloadAllComponents()
        
        if filtering {
            self.showAllGroupsButton.title = "Turn Smart Filter On"
        } else {
            self.showAllGroupsButton.title = "Show All Groups"
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        guard let groups = groups else { return "" }
        
        if filtering {
            if let filteredGroups = filteredGroups
                where filteredGroups.count > 0 {
                    return filteredGroups[row]["name"] as? String
            }
        }
        
        return groups[row]["name"] as? String
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        
        let index = pickerView.selectedRowInComponent(0)
        if let group = groups?[index] {
            print("Picked: \(group["name"])")
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func handleError(error:NSError?) {
        
        var message = "There was an error loading groups. That's all we know."
        if let error = error
            where error.localizedDescription.characters.count > 4 {
                message = error.localizedDescription
        }
        let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
