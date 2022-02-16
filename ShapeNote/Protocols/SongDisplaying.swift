//
//  SongDisplaying.swift
//  ShapeNote
//
//  Created by Charlie Williams on 31/07/2020.
//  Copyright © 2020 Charlie Williams. All rights reserved.
//

import UIKit

let favoritedString = "★"
let unfavoritedString = "☆"

protocol SongDisplaying: AnyObject {
    
    var song: Song! { get set }
    
    var numberLabel: UILabel! { get }
    var titleLabel: UILabel! { get }
    var infoLabel: UILabel! { get }
    var lyricsLabel: UILabel! { get }
    var meterAndTypeLabel: UILabel! { get }
    var favoriteButton: UIButton! { get }
}

extension SongDisplaying {
    
    var favoriteStateString: String {
        song?.favorited == true ? favoritedString : unfavoritedString
    }
    
    var favoriteStateAlpha: CGFloat {
        song?.favorited == true ? 1.0 : 0.3
    }
    
    func configureWithSong(_ song: Song) {
        
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
                if !infoString.isEmpty {
                    infoString += " "
                }
                infoString += meter
            }
        }
        if let type = song.type {
            if !type.hasPrefix("None") {
                if !infoString.isEmpty {
                    infoString += " "
                }
                infoString += type
            }
        }
        
        if let lyrics = song.lyrics, lyricsLabel != nil {
            
            if lyricsLabel.numberOfLines == 1 {
                lyricsLabel.text = lyrics.replacingOccurrences(of: "\n", with: " ")
            } else {
                lyricsLabel.text = lyrics
            }
            
        } else {
            lyricsLabel.text = nil
        }
        
        favoriteButton.setTitle(favoriteStateString, for: .normal)
        favoriteButton.alpha = favoriteStateAlpha
        
        meterAndTypeLabel.text = infoString
    }
}
