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
    
    var minutes:Minutes? // the minutes object, which is a collection of lessons
    var _lessons:[Lesson]?
    var lessons:[Lesson]? { // all of the lessons from the minutes object
        get {
            
            guard let minutes = minutes else { fatalError() }
            
            if _lessons == nil {
                
                var templessons = [Lesson]()
                if let loadedArray:NSOrderedSet = minutes.songs {
                    
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
    
        minutes?.complete = true
        CoreDataHelper.sharedHelper.saveContext()
        
        guard FacebookShareHelper.canPostToFacebook() else { self.navigationController?.popViewControllerAnimated(true); return }

        let alert = UIAlertController(title: "Post to Facebook?", message: nil, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Post", style: .Default) { (action:UIAlertAction) -> Void in
            
            FacebookShareHelper.postMinutesToFacebook(self.minutes!)
            self.navigationController?.popViewControllerAnimated(true)
        }
        let cancel = UIAlertAction(title: "Don't post", style: UIAlertActionStyle.Cancel) { (cancel:UIAlertAction!) -> Void in
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
            return lessons.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .ShortStyle
            
        if let lessons = lessons where lessons.count > indexPath.row {
            let lesson = lessons[indexPath.row]
            var string = lesson.song.number + " " + lesson.song.title + " – " + lesson.allLeadersString(useTwitterHandles: false)
            if let dedication = lesson.dedication {
                string += " (\(dedication))"
            }
            if let otherEvent = lesson.otherEvent {
                string = otherEvent
            }
            cell.textLabel!.text = string
            cell.detailTextLabel!.text = dateFormatter.stringFromDate(lesson.date)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // MARK: Header for new lesson
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if minutes?.complete == true {
            return nil
        }
        return tableView.dequeueReusableCellWithIdentifier("HeaderCell")
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if minutes?.complete == true {
            return 0
        }
        return tableViewHeaderHeight
    }
    
    
    // MARK: Navigation
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        
        if let minutes = minutes where parent == nil && minutes.songs.count == 0 {
            CoreDataHelper.managedContext.deleteObject(minutes)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationVC = segue.destinationViewController as? NewLessonViewController {
            destinationVC.minutes = minutes
        }
    }
}
