//
//  SongListTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

let favoritedString = ""
let unfavoritedString = ""

class SongListTableViewCell: UITableViewCell {
    
    var song:Song?
    var songListTableView:UITableView?
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var localChampionLabel: UILabel!
    @IBOutlet weak var meterAndTypeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    
    
    func configureWithSong(song:Song) {
        
        self.song = song
        
        if song.number.hasPrefix("0") {
            numberLabel.text = song.number.substringFromIndex(song.number.startIndex.advancedBy(1))
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
            if infoString.characters.count > 0 {
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
        
        let favoriteStateString = song.favorited ? favoritedString : unfavoritedString
        favoriteButton.setTitle(favoriteStateString, forState: .Normal)
        
        meterAndTypeLabel.text = infoString
    }
    
    @IBAction func favoriteButtonPressed(sender: UIButton) {
        guard let song = song else { fatalError("No song attached to cell") }
        song.favorited = !song.favorited
        self.songListTableView?.reloadData()
    }
    
}
