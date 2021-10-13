//
//  UserDefaults.swift
//  Luk
//
//  Created by Savio Mendes de Figueiredo on 10/12/21.
//

import Foundation

extension UserDefaults {
    private struct Constants {
        static let deviceIDKey = "Luk_DeviceID"
    }
    
    var deviceID: String {
        let defaults = UserDefaults.standard
        
        if let existingDeviceID = defaults.string(forKey: Constants.deviceIDKey) {
            return existingDeviceID
        }
        
        let newDeviceID = UUID().uuidString
        defaults.set(newDeviceID, forKey: Constants.deviceIDKey)
        
        return newDeviceID
    }
}
