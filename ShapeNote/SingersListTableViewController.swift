//
//  SingersListTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

class SingersListTableViewController: UITableViewController {

    var singers:[Singer] {
        let s:[Singer] = CoreDataHelper.sharedHelper.singers() as [Singer]
        let sortedSingers = s.sorted { (a:Singer, b:Singer) -> Bool in
            
//            // group by voice type
//            if (a.voice == b.voice) {
                return a.name < b.name
//            } else {
//                return a.voice < b.voice
//            }
        }
        return sortedSingers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let singer = singers[indexPath.row]
        cell.textLabel?.text = singer.name
        
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {

            let s = singers[indexPath.row]
            CoreDataHelper.managedContext.deleteObject(s)
            CoreDataHelper.save()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let dvc:UIViewController = segue.destinationViewController as UIViewController
        
        if let svc = dvc as? SingerViewController {

            if let indexPath = tableView.indexPathForSelectedRow() {
                let s = singers[indexPath.row]
                svc.singer = s
            }
        }
    }

}
