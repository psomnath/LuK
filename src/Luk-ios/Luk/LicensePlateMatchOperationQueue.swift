//
//  LicensePlateMatchOperationQueue.swift
//

import Foundation
import CoreLocation

public class LicensePlateMatchOperationQueue {
    private let operationQueue: OperationQueue
    private let amberAlertNetworkMatchReport: AmberAlertNetworkMatchReport

    init (amberAlertNetworkMatchReport: AmberAlertNetworkMatchReport) {
        self.amberAlertNetworkMatchReport = amberAlertNetworkMatchReport
        operationQueue = OperationQueue.main
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
        operationQueue.name = "LicensePlateMatchQueue"
    }

    func cancelAllOperations() {
        operationQueue.cancelAllOperations()
    }

    func addOperation(model: AmberAlertModel, latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, completion: @escaping (Error?) -> Void) {
        guard !hasAmberAlertInQueue(model) else {
            print("Amber alert with id \(model.licensePlateNo) will be skipped because it is already in the queue")
            return
        }

        print("Amber alert with id \(model.licensePlateNo) will be added to the queue")
        let operation = LicensePlateMatchOperation(model: model,
                                                   latitude: latitude,
                                                   longitude: longitude,
                                                   amberAlertNetworkMatchReport: self.amberAlertNetworkMatchReport,
                                                   completion: completion)
        
        operationQueue.addOperation(operation)
    }

    private func hasAmberAlertInQueue(_ model: AmberAlertModel) -> Bool {
        guard !operationQueue.operations.isEmpty else {
            return false
        }
        
        return operationQueue.operations.contains(where: { operation in
            guard let operation = operation as? LicensePlateMatchOperation, operation.model.alertId == model.alertId, (operation.state == .executing || operation.state == .ready) else {
                return false
            }
            
            return true
        })
    }
}
