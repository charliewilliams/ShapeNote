//
//  PFKeys.swift
//  ShapeNote
//
//  Created by Charlie Williams on 07/02/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import Foundation

enum PFKeys: String {
    case name = "name"
}

public let localHost = "http://localhost:1337/parse"
public let appId = "com.charliewilliams.ShapeNote"

public struct Config {
    public let id: String
    public let key: String
    public let url: String
}

public let sandbox = Config(id: "0YYog5pb5aCTUfaUyZdsZ22SREVd9SVJ1NQk5wyE", key: "dnD2BN0PhqOiJurEmSpLFcUTEHuneJeat4CXnnyH", url: "https://shapenote.herokuapp.com/parse")
public let local = Config(id: sandbox.id, key: sandbox.key, url: localHost)

// ****
// HERE IS THE SWITCH TO CHANGE AMONG SANDBOX, DEV and PROD
//public let activeConfig = local
public let activeConfig = sandbox
// ****
