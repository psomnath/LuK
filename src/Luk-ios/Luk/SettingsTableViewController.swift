//
//  SettingsTableViewController.swift
//

import Foundation
import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    private enum RowTag: Int {
        case phoneNumber
        case testLicensePlate
        case testAlertText
    }
    
    init() {
        super.init(style: .grouped)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = true
        self.tableView.isUserInteractionEnabled = true
        self.tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.reusableIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == RowTag.phoneNumber.rawValue {
            return "Phone Number"
        } else if section == RowTag.testLicensePlate.rawValue {
            return "Test license plate"
        } else if section == RowTag.testAlertText.rawValue {
            return "Test Alert Text"
        }

        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        }
        
        return UITableViewCell()
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
