//
//  BookPickerTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 10/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if books?.count > 0 {
            return books!.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 

        if let b = books {
            let book = b[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = book.title
            cell.detailTextLabel?.text = book.hashTag
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        if let title = cell?.textLabel?.text {
            Defaults.currentlySelectedBookTitle = title
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}
