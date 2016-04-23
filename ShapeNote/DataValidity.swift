//
//  DataValidity.swift
//  ShapeNote
//
//  Created by Charlie Williams on 23/04/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import Foundation

let oneDayAgoSecs = -60*60*24
let yesterday = NSDate(timeInterval: NSTimeInterval(oneDayAgoSecs), sinceDate: NSDate())
let lastWeekPlusOneDay = NSTimeInterval(oneDayAgoSecs * 8)