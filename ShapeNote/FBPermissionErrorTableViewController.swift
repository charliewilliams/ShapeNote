//
//  FBPermissionErrorTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 10/02/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

let missingPermissionsSection = 0
let instructionsSection = 1

class FBPermissionErrorTableViewController: UITableViewController {
    
    var missingPermissions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = "FBPermissionsErrorTableViewCell"
        tableView.registerNib(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == missingPermissionsSection {
            return missingPermissions.count
        } else {
            return 2
        }
    }
    
    var permissionDefinitions: [String:(String, String)] {
        
        return ["user_groups":("Your Groups", "We look at what ShapeNote groups you're in to match you with your singing group."),
            "publish_actions":("Publish Stories", "We use this permission to publish minutes that you take."),
            "publish_pages":("Publish to Pages", "We use this permission to publish minutes that you take on your group's page."),
            "manage_pages":("Manage Pages", "We use this permission to publish minutes that you take on your group's page, and to tag singers in the minutes you take.")
        ]
    }
    
    var instructionSets: [(String, String)] {
        return [("Re-enable permissions", ""),
        ("We take your privacy seriously", "ShapeNote will never post without your permissions, or without giving you the chance to choose exactly what you post.")]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FBPermissionsErrorTableViewCell", forIndexPath: indexPath) as! FBPermissionsErrorTableViewCell

        if indexPath.section == missingPermissionsSection {
            
            let missingPermission = missingPermissions[indexPath.row]
            let textTuple = permissionDefinitions[missingPermission]!
            cell.headlineLabel.text = textTuple.0
            cell.detailLabel.text = textTuple.1
            
        } else {
            
            let instruction = instructionSets[indexPath.row]
            cell.headlineLabel.text = instruction.0
            cell.detailLabel.text = instruction.1
            
        }

        return cell
    }
}
