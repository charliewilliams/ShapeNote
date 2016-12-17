//
//  Collection.swift
//  ShapeNote
//
//  Created by Charlie Williams on 17/12/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import Foundation

extension Set {
    
    func random() -> Element? {
        guard count > 0 else { return nil }
        guard count > 1 else { return first }
        let i = index(startIndex, offsetBy: Int(arc4random_uniform(UInt32(count))))
        assert(i <= endIndex)
        return self[i]
    }
}

extension Array {
    
    func random() -> Element? {
        guard count > 0 else { return nil }
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
}

extension Collection {
    
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    
    mutating func shuffleInPlace() {
        
        guard count > 1 else { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
