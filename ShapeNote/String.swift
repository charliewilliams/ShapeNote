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
        return substring(from: startIndex, to: index(startIndex, offsetBy: to));
    }

    func substring(from: Int) -> String {
        return substring(from: index(startIndex, offsetBy: from), to: index(startIndex, offsetBy: count))
    }

    func substring(from: Int, to: Int) -> String {

        let start = index(startIndex, offsetBy: from)
        let end = index(startIndex, offsetBy: to)
        return substring(from: start, to: end)
    }

    func substring(from: Index, to: Index) -> String {
        return String(self[from..<to])
    }
}
