//
//  SettingsTableViewController.swift
//

import Foundation
import UIKit
import CoreLocation

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    private enum RowTag: Int {
        case phoneNumber
        case testLicensePlate
        case testAlertText
        case amberAlertsTable
    }
    private var amberAlerts = [AmberAlertModel]()
    private let ambertAlertNetworkFetcher: AmberAlertNextworkFetcher
    private let amberAlertNetworkMatchReport: AmberAlertNetworkMatchReport
    private var latitude: CLLocationDegrees?
    private var longitude: CLLocationDegrees?
    
    init() {
        self.ambertAlertNetworkFetcher = AmberAlertNextworkFetcher()
        self.amberAlertNetworkMatchReport = AmberAlertNetworkMatchReport()
        super.init(style: .grouped)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = true
        self.tableView.isUserInteractionEnabled = true
        self.tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.reusableIdentifier)
        self.tableView.register(AmberAlertCell.self, forCellReuseIdentifier: AmberAlertCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == RowTag.phoneNumber.rawValue {
            return "Phone Number"
        } else if section == RowTag.testLicensePlate.rawValue {
            return "Test license plate"
        } else if section == RowTag.testAlertText.rawValue {
            return "Test Alert Text"
        } else if section == RowTag.amberAlertsTable.rawValue{
            return "Active Amber Alerts"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == RowTag.amberAlertsTable.rawValue){
            return amberAlerts.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == RowTag.phoneNumber.rawValue {
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.reusableIdentifier, for: indexPath) as? TextTableViewCell {
                cell.selectionStyle = .none
                cell.dataTextField.delegate = self
                cell.dataTextField.text = UserDefaults.standard.phoneNumber
                cell.dataTextField.tag = RowTag.phoneNumber.rawValue
                cell.placeholder = "Number to be called."
                cell.isUserInteractionEnabled = true

                return cell
            }
        } else if indexPath.section == RowTag.testLicensePlate.rawValue {
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.reusableIdentifier, for: indexPath) as? TextTableViewCell {
                cell.selectionStyle = .none
                cell.dataTextField.delegate = self
                cell.dataTextField.text = UserDefaults.standard.testLicensePlate
                cell.dataTextField.tag = RowTag.testLicensePlate.rawValue
                cell.placeholder = "Test License Plate"
                cell.isUserInteractionEnabled = true

                return cell
            }
        } else if indexPath.section == RowTag.testAlertText.rawValue {
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.reusableIdentifier, for: indexPath) as? TextTableViewCell {
                cell.selectionStyle = .none
                cell.dataTextField.delegate = self
                cell.dataTextField.text = UserDefaults.standard.testAlertText
                cell.dataTextField.tag = RowTag.testAlertText.rawValue
                cell.placeholder = "Test Alert Text"
                cell.isUserInteractionEnabled = true

                return cell
            }
        } else if indexPath.section == RowTag.amberAlertsTable.rawValue{
                return tableViewAmberAlerts(tableView, cellForRowAt: indexPath)
        }
        
        return UITableViewCell()
    }
    func tableViewAmberAlerts(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < amberAlerts.count else {
            return UITableViewCell()
        }
     
        let amberAlert = self.amberAlerts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AmberAlertCell.reuseIdentifier, for: indexPath) as! AmberAlertCell
        cell.update(model: amberAlert)
        cell.delegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == RowTag.amberAlertsTable.rawValue){
            return 70
        }
        return 40
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func valueChanged(_ textField: UITextField) {
        if textField.tag == RowTag.phoneNumber.rawValue {
            UserDefaults.standard.updatePhoneNumber(phoneNumber: textField.text ?? "")
        } else if textField.tag == RowTag.testLicensePlate.rawValue {
            UserDefaults.standard.updateTestLicensePlate(testLicensePlate: textField.text ?? "")
        } else if textField.tag == RowTag.testAlertText.rawValue {
            UserDefaults.standard.updateTestAlertText(testAlertText: textField.text ?? "")
        }
    }
}


extension SettingsTableViewController: AmberAlertCellDelegate {
    func didTapReportIt(model: AmberAlertModel?) {
        guard let model = model else {
            return
        }

        let alert = UIAlertController(title: "", message: "Do you want to report license plate \(model.licensePlateNo)?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Tell LuK", style: .default, handler: { [weak self] _ in
            self?.report(model: model)
        }))

        alert.addAction(UIAlertAction(title: "Call 911", style: .destructive, handler: { [weak self] _ in
            let matchModel = AmberAlertMatchModel(amberAlertModel: model, latitude: self?.latitude, longitude: self?.longitude, capturedTimeStamp: Date(), plateModel: nil)
            self?.amberAlertNetworkMatchReport.report(model: matchModel) { _ in }
            self?.call911()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func report(model: AmberAlertModel) {
        let matchModel = AmberAlertMatchModel(amberAlertModel: model, latitude: self.latitude, longitude: self.longitude, capturedTimeStamp: Date(), plateModel: nil)
        self.amberAlertNetworkMatchReport.report(model: matchModel) { [weak self] error in
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
    
    func sendLocalNotification(licencePlateNo: String?) {
        guard let licencePlateNo = licencePlateNo else {
            return
        }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Amber Alert detected"
        content.body = "There is an Amber Alert issued for the licence plate number: \(licencePlateNo)."
        content.sound = .default
        content.categoryIdentifier = "AMBER_ALERT"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
                print ("Error = \(error?.localizedDescription ?? "error local notification")")
            }
        }
    }
    
    private func call911() {
        guard let url = URL(string: "tel://\(UserDefaults.standard.phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension SettingsTableViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "MONITOR_ACTION":
            if let vc = self.presentingViewController {
                if vc is PlateDetectorViewController {
                    return
                }
            }
            
            self.navigationController!.popToViewController(self, animated: true);
            let plateDetectorViewController = PlateDetectorViewController()
            self.navigationController?.present(plateDetectorViewController, animated: true, completion: nil)
        
        case "DISMISS_ACTION":
            break

        default:
            break
        }

        completionHandler()
    }
}

class TextTableViewCell: UITableViewCell {
    static let reusableIdentifier: String = "TextTableViewCell"
    
    let dataTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .preferredFont(forTextStyle: .body)
        return textField
    }()
    
    var placeholder: String? {
        didSet {
            dataTextField.placeholder = placeholder
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(dataTextField)
        
        NSLayoutConstraint.activate([
            dataTextField.heightAnchor.constraint(equalToConstant: 40),
            dataTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dataTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dataTextField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            dataTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
