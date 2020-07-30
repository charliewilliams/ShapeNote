//
//  DataValidity.swift
//  ShapeNote
//
//  Created by Charlie Williams on 23/04/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

let blueColor = UIColor(red: 0, green: 122 / 255.0, blue: 1, alpha: 1)

typealias Completion = (() -> ())
typealias NetworkCompletion = ((_ success: Bool, _ error: Error?) -> ())

let oneDayAgoSecs = -60*60*24
let yesterday = Date(timeInterval: TimeInterval(oneDayAgoSecs), since: Date())
let lastWeekPlusOneDay = TimeInterval(oneDayAgoSecs * 8)
