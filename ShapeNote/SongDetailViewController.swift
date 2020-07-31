//
//  SongDetailViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 31/07/2020.
//  Copyright © 2020 Charlie Williams. All rights reserved.
//

import UIKit

class SongDetailViewController: UIViewController, SongDisplaying {
    
    var song: Song!
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var meterAndTypeLabel: UILabel!
    @IBOutlet weak var lyricsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureWithSong(song)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        
        song.favorited = !song.favorited
        configureWithSong(song)
        
        CoreDataHelper.sharedHelper.saveContext()
    }
    
}
