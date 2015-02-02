//
//  MinutesListViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

class MinutesListViewController: UITableViewController {

    @IBOutlet weak var minutesListTableView: UITableView!
    
    var _minutes:[Minutes]?
    var minutes:[Minutes] {
        get {
            if _minutes == nil {
                
                // TODO concept of "current group"
                let group = CoreDataHelper.sharedHelper.groupWithName("Bristol")
                if let name = group?.name {
                    
                    navigationItem.title = name + ": Minutes"
                    if let m:[Minutes] = CoreDataHelper.sharedHelper.minutes(name) {
                        
                        _minutes = m.sorted { (a:Minutes, b:Minutes) -> Bool in
                            
                            return a.date.timeIntervalSince1970 > b.date.timeIntervalSince1970
                        }
                    }
                }
            }
            return _minutes!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return minutes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as MinutesTableViewCell
        
        let minute = minutes[indexPath.row]
        cell.configureWithMinutes(minute)
        
        return cell
    }
    
    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let dvc = segue.destinationViewController as UIViewController
        
        if let mtvc = dvc as? MinuteTakingViewController {
            
            let indexPath = minutesListTableView.indexPathForSelectedRow()
            if let index = indexPath?.row {
                mtvc.minutes = minutes[index]
            }
        }
    }


}
