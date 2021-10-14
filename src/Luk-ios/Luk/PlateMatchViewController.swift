//
//  PlateMatchViewController.swift
//

import Foundation
import UIKit

class PlateMatchViewController: UIViewController {
    private let model: AmberAlertMatchModel
    
    private let cancelButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.sizeToFit()
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(didTapCancel), for: .touchDown)

        return button
    }()
    
    private let call911: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitle("Call 911", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.sizeToFit()
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(didTapCall911), for: .touchDown)

        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return imageView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill

        return stackView
    }()
    
    init(model: AmberAlertMatchModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        
        self.titleLabel.text = "License plate match found for \(model.amberAlertModel.licensePlateNo)\nDo you want to call 911?"
        self.titleLabel.sizeToFit()

        self.imageView.image = self.model.plateModel?.image
        self.imageView.sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(containerStackView)
        
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        
        containerStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(call911)
        containerStackView.addArrangedSubview(cancelButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        titleLabel.sizeThatFits(CGSize(width: self.view.bounds.width - 20, height: .infinity))
        titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.bounds.size.height).isActive = true
    }
    
    @objc private func didTapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCall911() {
        guard let url = URL(string: "tel://\(UserDefaults.standard.phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
