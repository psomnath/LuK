//
//  AmberAlertsTableViewController.swift
//

import Foundation
import UIKit
import CoreLocation

class AmberAlertsTableViewController: UITableViewController {
    private let ambertAlertNetworkFetcher: AmberAlertNextworkFetcher
    private let amberAlertNetworkMatchReport: AmberAlertNetworkMatchReport
    private var amberAlerts = [AmberAlertModel]()
    private var locationManager: CLLocationManager
    private var latitude: CLLocationDegrees?
    private var longitude: CLLocationDegrees?
    
    init() {
        self.ambertAlertNetworkFetcher = AmberAlertNextworkFetcher()
        self.amberAlertNetworkMatchReport = AmberAlertNetworkMatchReport()
        self.locationManager = CLLocationManager()
        
        super.init(style: .grouped)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.allowsSelection = false
        self.tableView.register(AmberAlertCell.self, forCellReuseIdentifier: AmberAlertCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "LUK"
        
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        button.setTitle("Start monitoring", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.sizeToFit()
        button.backgroundColor = .darkGray
        self.tableView.addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: self.tableView.layoutMarginsGuide.bottomAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: self.tableView.layoutMarginsGuide.trailingAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: self.tableView.layoutMarginsGuide.leadingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.tableView.layoutMarginsGuide.bottomAnchor, constant: -button.bounds.size.height).isActive = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @objc func buttonAction(_ sender: UIButton!) {
        let plateDetectorViewController = PlateDetectorViewController()
        self.navigationController?.present(plateDetectorViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.startUpdatingLocation()
        
        self.ambertAlertNetworkFetcher.fetchAmberAlerts { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                
            case .success(let amberAlerts):
                DispatchQueue.main.async {
                    self?.amberAlerts = amberAlerts
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amberAlerts.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        
        let header = UITableViewHeaderFooterView()
        header.textLabel?.text = "Active Amber Alerts"
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < amberAlerts.count else {
            return UITableViewCell()
        }
     
        let amberAlert = self.amberAlerts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AmberAlertCell.reuseIdentifier, for: indexPath) as! AmberAlertCell
        cell.update(model: amberAlert)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let verticalPadding: CGFloat = 8

        let maskLayer = CALayer()
        maskLayer.cornerRadius = 10
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension AmberAlertsTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            print ("\(self.latitude ?? 0) \(self.longitude ?? 0)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("Error getting the user s location \(error.localizedDescription)")
    }
}

extension AmberAlertsTableViewController: AmberAlertCellDelegate {
    func didTapReportIt(model: AmberAlertModel?) {
        guard let model = model else {
            return
        }

        let alert = UIAlertController(title: "", message: "Do you want to report license plate \(model.licensePlateNo)?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Report it", style: .default, handler: { [weak self] _ in
            self?.report(model: model)
        }))

        alert.addAction(UIAlertAction(title: "Call 911", style: .destructive, handler: { [weak self] _ in
            self?.amberAlertNetworkMatchReport.report(model: model, latitude: self?.latitude, longitude: self?.longitude) { _ in }
            self?.call911()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func report(model: AmberAlertModel) {
        self.amberAlertNetworkMatchReport.report(model: model, latitude: self.latitude, longitude: self.longitude) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                    
                    let alert = UIAlertController(title: "", message: "Failed to report \(model.licensePlateNo).", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self?.present(alert, animated: true)
                    
                    return
                }
                
                let alert = UIAlertController(title: "", message: "License plate \(model.licensePlateNo) has been reported.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self?.present(alert, animated: true)
            }
        }
    }
    
    private func call911() {
        guard let url = URL(string: "tel://\("")"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
