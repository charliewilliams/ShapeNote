//
//  SongListTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

class SongListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var localChampionLabel: UILabel!
    @IBOutlet weak var meterAndTypeLabel: UILabel!

    func configureWithSong(song:Song) {
        
        if song.number.hasPrefix("0") {
            numberLabel.text = song.number.substringFromIndex(advance(song.number.startIndex, 1))
        } else {
            numberLabel.text = song.number
        }
        titleLabel.text = song.title
        var infoString = ""
        
        if song.composer.utf16Count > 0 {
            infoString += song.composer
        }
        
        if let lyricist = song.lyricist {
            if !lyricist.hasPrefix("None") {
                infoString += " " + lyricist
            }
        }
        if (song.year > 0) {
            if (infoString.utf16Count > 0) {
                infoString += ", "
            }
            infoString += "\(song.year)"
        }
        infoLabel.text = infoString
        
        infoString = ""
        if song.meter.utf16Count > 0 && !song.meter.hasPrefix("None") {
            infoString += " " + song.meter
        }
        if song.type.utf16Count > 0 && !song.type.hasPrefix("None") {
            infoString += " " + song.type
        }
        
        meterAndTypeLabel.text = infoString
    }

}
