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
                
                let group = CoreDataHelper.sharedHelper.currentlySelectedGroup
                    
                navigationItem.title = group.name + ": Minutes"
                if let m:[Minutes] = CoreDataHelper.sharedHelper.minutes(group) {
                    
                    _minutes = m.sorted { (a:Minutes, b:Minutes) -> Bool in
                        
                        return a.date.timeIntervalSince1970 > b.date.timeIntervalSince1970
                    }
                }
            }
            println("\(_minutes?.count) Minutes")
            return _minutes!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: - Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var m:Minutes
        
        if minutes.count > indexPath.row+1 {
            m = minutes[indexPath.row]
        } else {
            m = NSEntityDescription.insertNewObjectForEntityForName("Minutes", inManagedObjectContext: CoreDataHelper.sharedHelper.managedObjectContext!) as Minutes
        }
        
        let minutesViewController = MinuteTakingViewController()
        minutesViewController.minutes = m
        
        self.navigationController?.pushViewController(minutesViewController, animated: true)
    }
}
