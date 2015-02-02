//
//  MinuteTakingViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

class MinuteTakingViewController: UITableViewController {
    
    @IBOutlet var minutesTableView: UITableView!
    var minutes:Minutes?
    var _leadings:[Leading]?
    var leadings:[Leading] {
        get {
            if _leadings == nil {
                
                if let loaded = minutes?.songs as? [Leading] {
                    
                    _leadings = loaded
                }
            }
            
            return _leadings!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .MediumStyle
        
        navigationItem.title = "Minutes: " + dateFormatter.stringFromDate(NSDate())
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if minutes == nil {
            
            // start taking new minutes
        } else {
            
            minutesTableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = minutes?.songs.count {
            return count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as MinutesTableViewCell
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        
        let leading = leadings[indexPath.row]
        cell.mainLabel.text = leading.song.number + " " + leading.song.title + " – " + leading.leader.name
        cell.detailLabel.text = dateFormatter.stringFromDate(leading.date)
        
        return cell
    }
}
