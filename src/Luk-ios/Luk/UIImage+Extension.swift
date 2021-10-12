//
//  UIImage+Extension.swift
//


import Foundation
import UIKit
import CoreImage
import VideoToolbox

extension UIImage {
    convenience init?(pixelBuffer: CVPixelBuffer?) {
        guard let pixelBuffer = pixelBuffer else {
            return nil
        }
        
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
    
    func crop(using boundingBox: CGRect, imageSize: CGSize) -> UIImage? {
        let convertedBox = boundingBox.convertBoundingBox(size: imageSize)
        
        let factor = self.size.width / imageSize.width
        let rect = CGRect(x: convertedBox.origin.x * factor,
                          y: convertedBox.origin.y * factor,
                          width: convertedBox.width * factor,
                          height: convertedBox.height * factor)
        
        guard let cgImage = self.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

extension CGRect {
    func convertBoundingBox(size: CGSize) -> CGRect {
        let scale = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        return self.applying(transform).applying(scale)
    }
}
