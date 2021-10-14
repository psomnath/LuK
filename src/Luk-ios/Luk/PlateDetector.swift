//
//  PlateDetector.swift
//

import Foundation
import Vision
import CoreImage
import UIKit
import VideoToolbox

protocol PlateDetectorDelegate: NSObjectProtocol {
    func plateDetector(didDetectPlates plates: [PlateModel])
}

class PlateDetector {
    private lazy var visionRequest: VNCoreMLRequest? = {
        guard let model = Self.visionModel() else {
            return nil
        }

        let request = VNCoreMLRequest(model: model, completionHandler: visionRequestCompleted)
        request.imageCropAndScaleOption = .scaleFill
        
        return request
    }()

    private var buffer: CVPixelBuffer?
    private var imageBounds: CGRect?
    private let group = DispatchGroup()
    
    weak var delegate: PlateDetectorDelegate?
    
    func detectPlates(buffer: CVPixelBuffer, imageBounds: CGRect) {
        guard let visionRequest = self.visionRequest, self.buffer == nil else {
            return
        }
        
        self.buffer = buffer
        self.imageBounds = imageBounds

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: buffer)
        try? requestHandler.perform([visionRequest])
    }
    
    private func visionRequestCompleted(request: VNRequest, error: Error?) {
        guard let predictions = request.results as? [VNRecognizedObjectObservation] else {
            DispatchQueue.main.async { [weak self] in self?.delegate?.plateDetector(didDetectPlates: []) }
            self.buffer = nil
            self.imageBounds = nil
            return
        }
        
        guard let imageBounds = self.imageBounds, let buffer = self.buffer, let fullImage = UIImage(pixelBuffer: buffer) else {
            DispatchQueue.main.async { [weak self] in self?.delegate?.plateDetector(didDetectPlates: []) }
            self.buffer = nil
            self.imageBounds = nil
            return
        }
        
        let boundingBoxes: [CGRect] = predictions.compactMap { $0.boundingBox }
        
        guard !boundingBoxes.isEmpty else {
            DispatchQueue.main.async { [weak self] in self?.delegate?.plateDetector(didDetectPlates: []) }
            self.buffer = nil
            self.imageBounds = nil

            return
        }
        
        var plates = [PlateModel]()
        
        for boundingBox in boundingBoxes {
            group.enter()
            
            guard let croppedImage = fullImage.crop(using: boundingBox, imageSize: imageBounds.size) else {
                group.leave()
                continue
            }
            
            self.detectText(boundingBox: boundingBox, croppedImage: croppedImage) { [weak self] newPlates in
                plates.append(contentsOf: newPlates)
                self?.group.leave()
            }
        }
        
        group.wait()
        
        self.buffer = nil
        self.imageBounds = nil
        DispatchQueue.main.async {
            self.delegate?.plateDetector(didDetectPlates: plates)
        }
    }

    private func detectText(boundingBox: CGRect, croppedImage: UIImage, completion: @escaping ([PlateModel]) -> Void) {
        guard let cgImage = croppedImage.cgImage, let imageSize = self.imageBounds?.size else {
            completion([])
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation]  else {
                completion ([])
                return
            }

            var recognizedTexts = [VNRecognizedText]()
            for observation in observations {
                recognizedTexts.append(contentsOf: observation.topCandidates(5))
            }
            
            guard !recognizedTexts.isEmpty else {
                completion([])
                return
            }
            
            let box = boundingBox.convertBoundingBox(size: imageSize)
            let plateModels: [PlateModel] = recognizedTexts.compactMap { PlateModel(licensePlate: $0.string, box: box, image: croppedImage) }
            
            completion(plateModels)
        }

        request.recognitionLevel = .accurate
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        do {
            try requestHandler.perform([request])
        } catch {
            completion([])
        }
    }
    
    private static func visionModel() -> VNCoreMLModel? {
        guard let mlModel: MLModel = try? model_plate_turi(configuration: MLModelConfiguration()).model else {
            return nil
        }
        
        return try? VNCoreMLModel(for: mlModel)
    }
}
