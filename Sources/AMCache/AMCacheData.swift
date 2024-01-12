//
//  CacheManagerData.swift
//
//
//  Created by Alex Maggio on 12/01/2024.
//

import Foundation

public class AMCacheData: Codable {
    var requestDate: Date
    var response: String
    var data: Data
    
    init(requestDate: Date = Date(), response: String, data: Data) {
        self.requestDate = requestDate
        self.response = response
        self.data = data
    }
}

extension AMCacheData {
    var isExpired: Bool {
        return (requestDate.timeIntervalSince1970 + CacheConfiguration.expiration) < Date().timeIntervalSince1970
    }
}
