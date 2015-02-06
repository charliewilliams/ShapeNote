//
//  MinuteTakingViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

class MinuteTakingViewController: UITableViewController {
    
    @IBOutlet weak var minutesTableView: UITableView!
    @IBOutlet weak var newSongButton: UIBarButtonItem!
    
    var minutes:Minutes?
    var leadings:[Leading]? {
        get {
            
            var ll:[Leading] = []
            if let l:NSOrderedSet = minutes?.songs {
                
                l.enumerateObjectsUsingBlock { (lll:AnyObject!, i, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                    ll.append(lll as Leading)
                }
            }

            return ll
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
        
        if leadings == nil || leadings?.count == 0 {
            newSongCalled(self.newSongButton)
        } else {
            minutesTableView.reloadData()
        }
    }
    
    @IBAction func newSongCalled(sender: UIBarButtonItem) {
        
        if minutes == nil {
            minutes = NSEntityDescription.insertNewObjectForEntityForName("Minutes", inManagedObjectContext: CoreDataHelper.managedContext!) as? Minutes
            minutes?.date = NSDate()
            minutes?.book = CoreDataHelper.sharedHelper.books().first!
            minutes?.group = CoreDataHelper.sharedHelper.groupWithName("Bristol")!
            CoreDataHelper.save()
        }
        
        if let nvc = storyboard?.instantiateViewControllerWithIdentifier("NewLeadingViewController") as? NewLeadingViewController {
            
            nvc.minutes = minutes
            self.navigationController?.pushViewController(nvc, animated: false)
        }
        
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
        
        // save and dismiss
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .ShortStyle
            
            if let leading = leadings?[indexPath.row] {
                cell.textLabel!.text = leading.song.number + " " + leading.song.title + " – " + leading.leader.name
                cell.detailTextLabel!.text = dateFormatter.stringFromDate(leading.date)
            }
            
            return cell
    }
}
