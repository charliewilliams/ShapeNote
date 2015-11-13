//
//  MinuteTakingViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData
import Social

class MinuteTakingViewController: UITableViewController {
    
    @IBOutlet weak var minutesTableView: UITableView!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    var minutes:Minutes? // the minutes object
    var _lessons:[Lesson]?
    var lessons:[Lesson]? { // all of the lessons from the minutes object
        get {
            
            guard minutes != nil else { return nil }
            
            if _lessons == nil {
                
                var templessons = [Lesson]()
                if let loadedArray:NSOrderedSet = minutes?.songs {
                    
                    loadedArray.enumerateObjectsUsingBlock { (lesson:AnyObject!, i, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                        
                        templessons.append(lesson as! Lesson)
                    }
                    _lessons = templessons.sort({ (first:Lesson, second:Lesson) -> Bool in
                        return first.date.timeIntervalSince1970 > second.date.timeIntervalSince1970
                    })
                }
            }
            return _lessons
        }
    }
    
    func setNeedsReload() {
        _lessons = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.enabled = false

        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .MediumStyle
        
        if let date = minutes?.date {
            navigationItem.title = "Minutes: " + dateFormatter.stringFromDate(date)
        }
    }

    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        setNeedsReload() //?
        minutesTableView.reloadData()
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
    
        CoreDataHelper.sharedHelper.saveContext()
        
        if FacebookShareHelper.canPostToFacebook() == false {
            return
        }

        let alert = UIAlertController(title: "Post to Facebook?", message: nil, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Do it", style: .Default) { (action:UIAlertAction) -> Void in
            
            FacebookShareHelper.postMinutesToFacebook(self.minutes!)
            self.navigationController?.popViewControllerAnimated(true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (cancel:UIAlertAction!) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let lessons = lessons {
            doneButton.enabled = true
            return lessons.count + 1
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return tableView.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .ShortStyle
            
        if let lessons = lessons where lessons.count > indexPath.row {
            let lesson = lessons[indexPath.row]
            cell.textLabel!.text = lesson.song.number + " " + lesson.song.title + " – " + lesson.allLeadersString(useTwitterHandles: false)
            cell.detailTextLabel!.text = dateFormatter.stringFromDate(lesson.date)
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationVC = segue.destinationViewController as? NewLessonViewController {
            destinationVC.minutes = minutes
        }
    }
}
