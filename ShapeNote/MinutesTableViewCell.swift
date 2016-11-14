//
//  MinutesTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 02/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

class MinutesTableViewCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var minutes:Minutes?

    func configureWithMinutes(_ minutes:Minutes, dateFormatter: DateFormatter) {
        
        self.minutes = minutes
        self.mainLabel.text = dateFormatter.string(from: minutes.date as Date)
        
        let songs = minutes.songs.count
        let singers = minutes.singers.count
        self.detailLabel.text = "\(songs) songs, \(singers) singers"
    }

}
