//
//  GroupsPickerViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 06/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit
import SwiftSpinner

enum PFKey:String {
    case name = "name"
    case group = "group"
    case singer = "Singer"
    case groups = "groups"
    case fbGroupID = "fbGroupID"
}

class GroupsPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // TODO sort by distance!
    
    var _groups:[Group]?
    var groups:[Group] {
        if _groups == nil {
            _groups = CoreDataHelper.sharedHelper.groups()
        }
        return _groups!
    }
    var filtering = true
    @IBOutlet var pickerView: UIPickerView!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groups.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return groups[row].name
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func setGroupPressed(sender: AnyObject) {
        finish()
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
        finish()
    }
    
    func finish() {
        
        let index = pickerView.selectedRowInComponent(0)
        let group = groups[index]
        print("Picked: \(group.name)")
        
        guard let user = PFUser.currentUser() else {
            Defaults.currentGroupName = group.name
            ParseHelper.sharedHelper.didChangeGroup { [weak self] (result:RefreshCompletionAction) -> () in
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            return
        }
        
        SwiftSpinner.show("Saving…", animated: true)
        let saveGroup = dispatch_group_create()
        dispatch_group_enter(saveGroup)
        if let existingGroup = user[PFKey.group.rawValue] as? PFObject where existingGroup[PFKey.name.rawValue] as! String != group.name {
            
            let alert = UIAlertController(title: "Replace \(existingGroup[PFKey.name.rawValue])?", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Replace", style: .Default, handler: { (action:UIAlertAction) in
                
                ParseHelper.sharedHelper.saveGroup(group, onUser: user, completion: {
                    dispatch_group_leave(saveGroup)
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action:UIAlertAction) in
                dispatch_group_leave(saveGroup)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            ParseHelper.sharedHelper.saveGroup(group, onUser: user, completion: {
                dispatch_group_leave(saveGroup)
            })
        }
        
        dispatch_group_enter(saveGroup)
        ParseHelper.sharedHelper.didChangeGroup { (result:RefreshCompletionAction) -> () in
            dispatch_group_leave(saveGroup)
        }
        
        dispatch_group_notify(saveGroup, dispatch_get_main_queue()) { [weak self] () -> Void in
            SwiftSpinner.hide()
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
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
