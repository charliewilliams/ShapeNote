//
//  SongListTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

class SongListTableViewCell: UITableViewCell, SongDisplaying {
    
    var song: Song!
    var songListTableView: UITableView?
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel! /// Composer & date
    @IBOutlet weak var lyricsLabel: UILabel!
    @IBOutlet weak var meterAndTypeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        
        song.favorited = !song.favorited
        
        CoreDataHelper.sharedHelper.saveContext()
        
        songListTableView?.reloadData()
    }
    
}
