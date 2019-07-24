//
//  String.swift
//  ShapeNote
//
//  Created by Charlie Williams on 24/07/2019.
//  Copyright © 2019 Charlie Williams. All rights reserved.
//

import Foundation

extension String {

    func substring(to: Int) -> String {
        return substring(from: self.startIndex, to: self.index(self.startIndex, offsetBy: to));
    }

    func substring(from: Int) -> String {
        return substring(from: self.index(self.startIndex, offsetBy: from), to: self.index(self.startIndex, offsetBy: self.count))
    }

    func substring(from: Int, to: Int) -> String {

        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return substring(from: startIndex, to: endIndex)
    }

    func substring(from: Index, to: Index) -> String {
        return String(self[startIndex..<endIndex])
    }
}
