//
//  SongListTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

let favoritedString = "★"
let unfavoritedString = "☆"

class SongListTableViewCell: UITableViewCell {
    
    var song: Song?
    var songListTableView: UITableView?
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var lyricsLabel: UILabel!
    @IBOutlet weak var localChampionLabel: UILabel!
    @IBOutlet weak var meterAndTypeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var favoriteStateString: String {
        song?.favorited == true ? favoritedString : unfavoritedString
    }
    
    var favoriteStateAlpha:CGFloat {
        song?.favorited == true ? 1.0 : 0.3
    }

    func configureWithSong(_ song:Song) {
        
        self.song = song
        
        if song.number.hasPrefix("0") {
            numberLabel.text = song.number.substring(from: 1)
        } else {
            numberLabel.text = song.number
        }
        titleLabel.text = song.title
        var infoString = ""
        
        if let composer = song.composer {
            infoString += composer
        }
        
        if let lyricist = song.lyricist {
            if !lyricist.hasPrefix("None") {
                infoString += " " + lyricist
            }
        }
        if (song.year > 0) {
            if infoString.count > 0 {
                infoString += ", "
            }
            infoString += "\(song.year)"
        }
        infoLabel.text = infoString
        
        infoString = ""
        if let meter = song.meter {
            if !meter.hasPrefix("None") {
                infoString += " " + meter
            }
        }
        if let type = song.type {
            if !type.hasPrefix("None") {
                infoString += " " + type
            }
        }
        
        if let lyrics = song.lyrics, lyricsLabel != nil {
            lyricsLabel.text = lyrics.replacingOccurrences(of: "\n", with: " ")
        } else {
            lyricsLabel.text = nil
        }
        
        favoriteButton.setTitle(favoriteStateString, for: .normal)
        favoriteButton.alpha = favoriteStateAlpha
        
        meterAndTypeLabel.text = infoString
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        
        guard let song = song else { fatalError("No song attached to cell") }
        song.favorited = !song.favorited
        
        CoreDataHelper.sharedHelper.saveContext()
        
        self.songListTableView?.reloadData()
    }
    
}
