//
//  AmberAlertModel.swift
//

import Foundation

struct AmberAlertModel: Codable {
    let alertId: Int64
    let creationTimeStamp: String
    let licensePlateNo: String
    let alertText: String?
}
