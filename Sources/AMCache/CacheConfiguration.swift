//
//  CacheConfiguration.swift
//
//
//  Created by Alex Maggio on 12/01/2024.
//

import Foundation

enum CacheConfiguration {
    static let expiration: TimeInterval = 180
    static let dbFile: String = "db.dat"
    static let dumpEvery: Int = 3
}
