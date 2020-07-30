//
//  UILabel.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/07/2020.
//  Copyright © 2020 Charlie Williams. All rights reserved.
//

import UIKit

extension UILabel {
    
    @IBInspectable var kerning: Float {
        get {
            var range = NSMakeRange(0, (text ?? "").count)
            return attributedText?.attribute(.kern, at: 0, effectiveRange: &range) as? Float ?? 0
        }
        set {
            var attText: NSMutableAttributedString
            
            if let attributedText = attributedText {
                attText = NSMutableAttributedString(attributedString: attributedText)
            } else if let text = text {
                attText = NSMutableAttributedString(string: text)
            } else {
                attText = NSMutableAttributedString(string: "")
            }
            
            let range = NSMakeRange(0, attText.length)
            attText.addAttribute(.kern, value: NSNumber(value: newValue), range: range)
            self.attributedText = attText
        }
    }
}

