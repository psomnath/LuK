//
//  AmberAlertCell.swift
//

import Foundation
import UIKit
import UserNotifications

protocol AmberAlertCellDelegate: AnyObject {
    func didTapReportIt(model: AmberAlertModel?)
    func sendLocalNotification(licencePlateNo: String?)
}

class AmberAlertCell: UITableViewCell {
    static let reuseIdentifier: String = "AmberAlertCell"
    
    private var model: AmberAlertModel?
    weak var delegate: AmberAlertCellDelegate?
    
    private lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        button.setTitle("Report it", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.sizeToFit()
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(didTapReportIt), for: .touchDown)

        return button
    }()
    
    private lazy var plateLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var alertLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    public lazy var notificationButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        button.setTitle("Notify", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.sizeToFit()
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(sendLocalNotification), for: .touchDown)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.detailTextLabel?.font = .preferredFont(forTextStyle: .body)
        
        self.contentView.addSubview(plateLabel)
        self.contentView.addSubview(alertLabel)
        self.contentView.addSubview(button)
        self.contentView.addSubview(notificationButton)

        plateLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        plateLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        plateLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.button.leadingAnchor, constant: -10).isActive = true
        plateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        plateLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        alertLabel.topAnchor.constraint(equalTo: plateLabel.bottomAnchor, constant: 5).isActive = true
        alertLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        alertLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.button.leadingAnchor, constant: -10).isActive = true
        alertLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        alertLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        button.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: button.titleLabel!.heightAnchor, constant: 10).isActive = true
        button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        button.widthAnchor.constraint(equalTo: self.button.titleLabel!.widthAnchor, constant: 20).isActive = true
        button.titleLabel?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.titleLabel?.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        notificationButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        notificationButton.heightAnchor.constraint(equalTo: button.titleLabel!.heightAnchor, constant: 10).isActive = true
        notificationButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -100).isActive = true
        notificationButton.widthAnchor.constraint(equalTo: self.button.titleLabel!.widthAnchor, constant: 20).isActive = true
        notificationButton.titleLabel?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        notificationButton.titleLabel?.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(model: AmberAlertModel) {
        self.model = model
        self.plateLabel.text = "License Plate: \(model.licensePlateNo)"
        self.plateLabel.sizeToFit()
        
        self.alertLabel.text = model.alertText
        self.alertLabel.sizeToFit()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.textLabel?.text = nil
        self.detailTextLabel?.text = nil
    }
    
    @objc private func didTapReportIt() {
        delegate?.didTapReportIt(model: self.model)
    }
    
    @objc private func sendLocalNotification(){
        delegate?.sendLocalNotification(licencePlateNo: self.model?.licensePlateNo)
    }
}
