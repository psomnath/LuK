//
//  LicensePlateMatchOperation.swift
//

import Foundation
import CoreLocation

class LicensePlateMatchOperation: ConcurrentOperation {
    let model: AmberAlertMatchModel
    let completion: (Error?) -> Void
    let amberAlertNetworkMatchReport: AmberAlertNetworkMatchReport
    
    init(model: AmberAlertMatchModel,
         amberAlertNetworkMatchReport: AmberAlertNetworkMatchReport,
         completion: @escaping (Error?) -> Void) {
        self.model = model
        self.completion = completion
        self.amberAlertNetworkMatchReport = amberAlertNetworkMatchReport
        super.init()
    }

    var operation: Operation {
        return self
    }

    override func start() {
        print("Started for LicensePlateMatchOperation")
        guard !self.isCancelled else {
            print("Marked as finished since LicensePlateMatchOperation is cancelled.")
            self.state = .finished
            self.completion(NSError())
            return
        }

        print("Marked as executing LicensePlateMatchOperation")
        self.state = .executing
        self.execute()
    }

    private func execute() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.model.writeToPhotoAlbum()
        }

        amberAlertNetworkMatchReport.report(model: model) { [weak self] error in
            self?.completion(error)
            print("Marked as finished LicensePlateMatchOperation with result \(error == nil)")

            guard error == nil else {
                DispatchQueue.main.async {
                    self?.state = .finished
                }
                
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self?.state = .finished
            }
        }
    }
}
