//
//  CameraController.swift
//

import UIKit
import AVFoundation
import CoreVideo

protocol CameraControllerDelegate: AnyObject {
    func cameraController(didOutput buffer: CVPixelBuffer, at timestamp: CMTime)
}

class CameraController: NSObject {
    private var fps: Int
    private let captureSession: AVCaptureSession
    private let videoOutput: AVCaptureVideoDataOutput
    private let queue: DispatchQueue
    private var lastTimestamp: CMTime

    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CameraControllerDelegate?
    
    init?(fps: Int, sessionPreset: AVCaptureSession.Preset) {
        self.fps = fps
        self.queue = DispatchQueue(label: "com.microsoft.luk.camera_controller_queue")
        self.lastTimestamp = CMTime()
        self.videoOutput = AVCaptureVideoDataOutput()
        self.captureSession = AVCaptureSession()
        
        super.init()
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return nil
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return nil
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.connection?.videoOrientation = .portrait
        self.previewLayer = previewLayer
        
        let settings: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
        ]
        
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        captureSession.commitConfiguration()
    }
    
    func startCamera() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func stopCamera() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func viewPinched(recognizer: UIPinchGestureRecognizer) {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        
        switch recognizer.state {
            case .began:
                recognizer.scale = captureDevice.videoZoomFactor
            case .changed:
                let scale = recognizer.scale
                do {
                    try captureDevice.lockForConfiguration()
                    captureDevice.videoZoomFactor = max(captureDevice.minAvailableVideoZoomFactor, min(scale, captureDevice.maxAvailableVideoZoomFactor))
                    captureDevice.unlockForConfiguration()
                }
                catch {
                    print(error)
                }
            default:
                break
        }
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let delta = timestamp - lastTimestamp
        if delta >= CMTimeMake(value: 1, timescale: Int32(fps)) {
            lastTimestamp = timestamp
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }

            delegate?.cameraController(didOutput: imageBuffer, at: timestamp)
        }
    }
}
