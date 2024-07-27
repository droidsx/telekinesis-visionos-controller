//
//  UserDefaults+Extensions.swift
//  live-hands-tracking
//
//  Created by Yuriy Nefedov on 27.07.2024.
//

import Foundation

extension UserDefaults {
    
    private static let clientIdKey: String = "clientId"
    
    var clientId: String? {
        get {
            self.string(forKey: Self.clientIdKey)
        } set (newValue) {
            if let newValue {
                self.set(newValue, forKey: Self.clientIdKey)
            } else {
                self.removeObject(forKey: Self.clientIdKey)
            }
        }
    }
    
    func issueClientIdIfNecessary() {
        if clientId == nil {
            self.clientId = UUID().uuidString
        }
    }
}
