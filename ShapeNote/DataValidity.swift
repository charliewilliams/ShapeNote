//
//  DataValidity.swift
//  ShapeNote
//
//  Created by Charlie Williams on 23/04/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import Foundation

typealias CompletionBlock = (() -> ())
typealias RefreshCompletionBlock = (RefreshCompletionAction -> ())

let oneDayAgoSecs = -60*60*24
let yesterday = NSDate(timeInterval: NSTimeInterval(oneDayAgoSecs), sinceDate: NSDate())
let lastWeekPlusOneDay = NSTimeInterval(oneDayAgoSecs * 8)

enum PFClass: String {
    case User = "PFUser"
    case Singer = "Singer"
    case Group = "Group"
}

enum PFKey: String {
    case name = "name"
    case group = "group"
    case groups = "groups"
    case facebookGroupId = "facebookGroupId"
    case associatedSingerObject = "singer"
    case firstName = "firstName"
    case lastName = "lastName"
    case displayName = "displayName"
    case voiceType = "voiceType"
    case twitter = "twitter"
    case facebookId = "facebookId"
    case firstSing = "firstSingDate"
    case lastSing = "lastSingDate"
}
