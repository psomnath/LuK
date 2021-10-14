//
//  AmberAlertMatchModel.swift
//

import Foundation
import CoreLocation
import UIKit

struct AmberAlertMatchModel {
    let amberAlertModel: AmberAlertModel
    let latitude: CLLocationDegrees?
    let longitude: CLLocationDegrees?
    let capturedTimeStamp: Date
    let plateModel: PlateModel?
    
    func writeToPhotoAlbum() {
        guard let image = plateModel?.image else {
            return
        }
        
        ImageSaver().writeToPhotoAlbum(image: image)
    }
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
