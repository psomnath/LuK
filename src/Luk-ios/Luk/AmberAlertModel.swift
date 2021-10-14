//
//  AmberAlertModel.swift
//

import Foundation
import CoreLocation

struct AmberAlertModel: Codable {
    let alertId: Int64
    let creationTimeStamp: String
    let licensePlateNo: String
    let alertText: String?
}

struct AmberAlertMatchModel {
    let amberAlertModel: AmberAlertModel
    let latitude: CLLocationDegrees?
    let longitude: CLLocationDegrees?
    let capturedTimeStamp: Date
}
