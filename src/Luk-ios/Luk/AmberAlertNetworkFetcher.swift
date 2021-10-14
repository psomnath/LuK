//
//  AmberAlertNetworkFetcher.swift
//

import Foundation

class AmberAlertNextworkFetcher {
    func fetchAmberAlerts(completion: @escaping (Result<[AmberAlertModel], Error>) -> Void) {
        guard let url = URL(string: "https://lukapi.azurewebsites.net/amberalert") else {
            completion(.failure(NSError(domain: "Amber Alert Network Fetcher", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                completion(.failure(NSError(domain: "Amber Alert Network Fetcher", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Amber Alert Network Fetcher", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
           
            print (String(data: data, encoding: .utf8) ?? "")
            
            do {
                var result: [AmberAlertModel] = try JSONDecoder().decode([AmberAlertModel].self, from: data)
                
                if UserDefaults.standard.testLicensePlate != "" {
                    result.append(AmberAlertModel(alertId: 0, creationTimeStamp: "0001-01-01T00:00:00", licensePlateNo: UserDefaults.standard.testLicensePlate, alertText: UserDefaults.standard.testAlertText))
                }
                
                completion(.success(result))
            } catch let error {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
