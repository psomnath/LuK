//
//  PlateDetectorViewController.swift
//

import UIKit
import Vision
import AVKit
import CoreMedia

class PlateDetectorViewController: UIViewController {
    
    private let plateDetector: PlateDetector = PlateDetector()
    private let cameraController: CameraController? = CameraController(fps: 30, sessionPreset: .vga640x480)
    private var imageBounds: CGRect?
    
    private let videoPreview: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var boxesViews: [UIView] = []

    private let plateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        view.backgroundColor = .black

        plateDetector.delegate = self
        
        view.addSubview(plateLabel)
        plateLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        plateLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        plateLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        plateLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(videoPreview)
        videoPreview.bottomAnchor.constraint(equalTo: plateLabel.topAnchor).isActive = true
        videoPreview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        videoPreview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        videoPreview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        cameraController?.delegate = self
        if let previewLayer = self.cameraController?.previewLayer {
            self.videoPreview.layer.addSublayer(previewLayer)
        }
        
        self.cameraController?.startCamera()
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        self.videoPreview.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
        self.cameraController?.viewPinched(recognizer: recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraController?.startCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cameraController?.stopCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraController?.previewLayer?.frame = videoPreview.bounds
        imageBounds = self.videoPreview.bounds
    }
    
    private func update(plateBounds: [CGRect]) {
        self.boxesViews.forEach { $0.removeFromSuperview() }
        self.boxesViews.removeAll()
        
        for plateBound in plateBounds {
            let boxView = UIView(frame: plateBound)
            boxView.layer.borderColor = UIColor.green.cgColor
            boxView.layer.borderWidth = 2
            boxView.backgroundColor = UIColor.clear
            
            self.videoPreview.addSubview(boxView)
            self.boxesViews.append(boxView)
        }

        self.videoPreview.setNeedsDisplay()
    }
}

extension PlateDetectorViewController: CameraControllerDelegate {
    func cameraController(didOutput buffer: CVPixelBuffer, at timestamp: CMTime) {
        plateDetector.detectPlates(buffer: buffer, imageBounds: imageBounds ?? CGRect.zero)
    }
}
 
extension PlateDetectorViewController: PlateDetectorDelegate {
    func plateDetector(didDetectPlates plates: [PlateModel]) {
        guard !plates.isEmpty else {
            self.plateLabel.text = nil
            return
        }
        
        self.plateLabel.text = plates.first?.licensePlate
        self.update(plateBounds: plates.compactMap({ $0.box }))
    }
}
