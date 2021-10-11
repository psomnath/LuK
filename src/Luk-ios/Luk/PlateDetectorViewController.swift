//
//  PlateDetectorViewController.swift
//

import UIKit
import Vision
import AVKit
import CoreMedia
import CoreLocation

class PlateDetectorViewController: UIViewController {
    
    private let plateDetector: PlateDetector
    private let cameraController: CameraController?
    private let ambertAlertNetworkFetcher: AmberAlertNextworkFetcher
    private var imageBounds: CGRect?
    private var amberAlerts = [AmberAlertModel]()
    private var locationManager: CLLocationManager
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
    
    init() {
        self.locationManager = CLLocationManager()
        self.plateDetector = PlateDetector()
        self.ambertAlertNetworkFetcher = AmberAlertNextworkFetcher()
        self.cameraController = CameraController(fps: 30, sessionPreset: .vga640x480)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        view.backgroundColor = .black

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
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
    @IBAction func startMonitoring(sender: UIButton){
        // populate local db with amber alert
        self.cameraController?.startCamera()
    }
    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
        self.cameraController?.viewPinched(recognizer: recognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraController?.startCamera()
        locationManager.startUpdatingLocation()
        
        self.ambertAlertNetworkFetcher.fetchAmberAlerts { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                
            case .success(let amberAlerts):
                DispatchQueue.main.async {
                    self?.amberAlerts = amberAlerts
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cameraController?.stopCamera()
        locationManager.stopUpdatingLocation()
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

extension PlateDetectorViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print ("\(latitude) \(longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("Error getting the user s location \(error.localizedDescription)")
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
