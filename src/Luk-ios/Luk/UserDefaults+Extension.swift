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
        static let phoneNumberKey = "Luk_PhoneNumber"
        static let testLicensePlateKey = "Luk_TestLicensePlateKey"
        static let testAlertTextKey = "Luk_TestAlertTextKey"
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
    
    var phoneNumber: String {
        return UserDefaults.standard.string(forKey: Constants.phoneNumberKey) ?? ""
    }
    
    func updatePhoneNumber(phoneNumber: String) {
        UserDefaults.standard.set(phoneNumber, forKey: Constants.phoneNumberKey)
    }
    
    var testLicensePlate: String {
        return UserDefaults.standard.string(forKey: Constants.testLicensePlateKey) ?? ""
    }
    
    func updateTestLicensePlate(testLicensePlate: String) {
        UserDefaults.standard.set(testLicensePlate, forKey: Constants.testLicensePlateKey)
    }
    
    var testAlertText: String {
        return UserDefaults.standard.string(forKey: Constants.testAlertTextKey) ?? ""
    }
    
    func updateTestAlertText(testAlertText: String) {
        UserDefaults.standard.set(testAlertText, forKey: Constants.testAlertTextKey)
    }
}
