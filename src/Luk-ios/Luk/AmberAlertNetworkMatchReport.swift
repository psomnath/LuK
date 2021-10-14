//
//  AmberAlertNetworkMatchReport.swift
//

import Foundation
import CoreLocation

class AmberAlertNetworkMatchReport {
    private let dateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }()

    func report(model: AmberAlertMatchModel, completion: @escaping (Error?) -> Void) {
        var parameters:  [String : Any] = ["alertId": model.amberAlertModel.alertId,
                                           "capturedTimeStamp": dateTimeFormatter.string(from: model.capturedTimeStamp),
                                           "licensePlateNo": model.amberAlertModel.licensePlateNo,
                                           "deviceId": UserDefaults.standard.deviceID,
                                           "geoLocation": self.geoLocation(latitude: model.latitude, longitude: model.longitude)]
        if let imageBase64String = model.plateModel?.image?.jpegData(compressionQuality: 1)?.base64EncodedString() {
            parameters["CapturedImageBytes"] = imageBase64String
        }
        
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
