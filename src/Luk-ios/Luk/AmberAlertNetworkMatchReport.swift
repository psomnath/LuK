//
//  AmberAlertNetworkMatchReport.swift
//

import Foundation
import CoreLocation

class AmberAlertNetworkMatchReport {
    func report(model: AmberAlertModel, latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, completion: @escaping (Error?) -> Void) {
        let parameters:  [String : Any] = ["alertId": model.alertId,
                                           "capturedTimeStamp": "0001-01-01T00:00:00",
                                           "licensePlateNo": model.licensePlateNo,
                                           "deviceId": UserDefaults.standard.deviceID,
                                           "geoLocation": self.geoLocation(latitude: latitude, longitude: longitude)]
        let url = URL(string: "https://lukapi.azurewebsites.net/amberalert/Report")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(error)
            return
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                completion(error)
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                completion(NSError(domain: "Amber Alert Network Match", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                return
            }
            
            guard let data = data else {
                completion(NSError(domain: "Amber Alert Network Match", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"]))
                return
            }

            let responseBody = String(data: data, encoding: .utf8)
            print("\(responseBody ?? "")")

            completion(nil)
        })
        task.resume()
    }
    
    private func geoLocation(latitude: CLLocationDegrees?, longitude: CLLocationDegrees?) -> String {
        guard let latitude = latitude, let longitude = longitude else {
            return ""
        }
        
        return "\(latitude),\(longitude)"
    }
}
