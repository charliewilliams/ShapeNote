//
//  SongListTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

class SongListTableViewController: UITableViewController {
    
    var _songs:[Song]?
    var songs:[Song] {
        get {
            if _songs == nil {
                
                let s:[Song] = CoreDataHelper.sharedHelper.songs(nil) as [Song]
                _songs = s.sorted { (a:Song, b:Song) -> Bool in
                    
                    // t and b are in the wrong order, alphabetically
                    if (a.strippedNumber == b.strippedNumber) {
                        return a.number > b.number
                    } else {
                        return a.number < b.number
                    }
                }
                
                navigationItem.title = _songs?.first?.book.title
            }
            return _songs!
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
        return songs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as SongListTableViewCell

        let song = songs[indexPath.row]
        cell.configureWithSong(song)

        return cell
    }

    // MARK: - Navigation
    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
}
