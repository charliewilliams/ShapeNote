//
//  GroupSelectionTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 12/11/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

let reuseIdentifier = "cell"

class GroupSelectionTableViewController: UITableViewController {
    
    let groups = ["Bristol", "Sheffield", "London", "Norwich", "Leeds", "Halifax", "Portland", "Nashville", "New York City", "Chicago", "Minneapolis", "Huntsville", "Boston", "Hamburg"]

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Other group…"
            cell.textLabel?.textColor = .white
            cell.backgroundColor = blueColor
            return cell
        }

        if indexPath.row < groups.count {
            cell.textLabel?.text = groups[indexPath.row]
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
            return cell
        }

        fatalError()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)!
        Defaults.currentGroupName = cell.textLabel!.text
        
        _ = navigationController?.popViewController(animated: true)
    }
}
