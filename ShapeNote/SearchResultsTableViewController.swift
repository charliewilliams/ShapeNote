//
//  SearchResultsTableView.swift
//  ShapeNote
//
//  Created by Charlie Williams on 13/12/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class SearchResultsTableViewController : UITableViewController {
    
    var results:[Song]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.registerClass(SongListTableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "SongListTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongListTableViewCell
        let song = results![indexPath.row]
        cell.configureWithSong(song)
        
        return cell
    }
}
