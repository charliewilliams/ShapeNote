//
//  NoMinutesYetView.swift
//  ShapeNote
//
//  Created by Charlie Williams on 14/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class NoMinutesYetView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let label = UILabel()
        label.text = "Minutes for your local singing will appear here.\n\nSign into Facebook to join your local singing,\nthen tap the cell above to get start taking minutes"
        label.textColor = UIColor.whiteColor()
        backgroundColor = blueColor.colorWithAlphaComponent(0.5)
    }

}
