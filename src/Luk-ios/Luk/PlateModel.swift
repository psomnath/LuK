//
//  PlateModel.swift
//  Luk
//

import Foundation
import UIKit

class PlateModel {
    let licensePlate: String
    let box: CGRect
    let image: UIImage?
    
    init(licensePlate: String, box: CGRect, image: UIImage?) {
        self.licensePlate = licensePlate
        self.box = box
        self.image = image
    }
}
