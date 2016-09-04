//
//  DataValidity.swift
//  ShapeNote
//
//  Created by Charlie Williams on 23/04/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import Foundation

typealias CompletionBlock = (() -> ())

let oneDayAgoSecs = -60*60*24
let yesterday = Date(timeInterval: TimeInterval(oneDayAgoSecs), since: Date())
let lastWeekPlusOneDay = TimeInterval(oneDayAgoSecs * 8)
