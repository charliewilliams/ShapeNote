//
//  GroupsPickerViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 06/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class GroupsPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var groups:[NSDictionary]?
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
    
    @IBAction func showAllGroupsPressed(sender: AnyObject) {
        self.filtering = !self.filtering
        self.pickerView.reloadAllComponents()
        
        if filtering {
            self.showAllGroupsButton.title = "Turn Smart Filter On"
        } else {
            self.showAllGroupsButton.title = "Show All My Groups"
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

}
