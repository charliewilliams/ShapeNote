//
//  BookPickerTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 10/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

class BookPickerTableViewController: UITableViewController {
    
    var _books:[Book]?
    var books:[Book]? {
        get {
            if _books == nil {
                _books = CoreDataHelper.sharedHelper.books()
            }
            return _books
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if books?.count > 0 {
            return books!.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 

        if let b = books {
            let book = b[indexPath.row]
            cell.textLabel?.text = book.title
            cell.detailTextLabel?.text = book.hashTag
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let title = cell?.textLabel?.text {
            Defaults.currentlySelectedBookTitle = title
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
