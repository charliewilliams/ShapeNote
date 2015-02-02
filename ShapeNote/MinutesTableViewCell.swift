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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureWithMinutes(minutes:Minutes) {
        
        self.minutes = minutes
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .FullStyle
        
        self.mainLabel.text = dateFormatter.stringFromDate(minutes.date)
        
        let songs = minutes.songs.count
        let singers = minutes.singers.count
        self.detailLabel.text = "\(songs) songs, \(singers) singers"
    }

}
