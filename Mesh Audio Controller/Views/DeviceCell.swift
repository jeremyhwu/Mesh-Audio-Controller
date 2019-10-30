//
//  DeviceCell.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 10/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {
    var deviceNameLabel = UILabel()
    var deviceIDLabel = UILabel()
    var deviceStateLabel = UILabel()
    var propertiesLabel = UILabel()
    var stackView : UIStackView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        addSubview(deviceNameLabel)
//        addSubview(deviceIDLabel)
//        addSubview(deviceStateLabel)
        let stackView = UIStackView()
        addSubview(stackView)
        stackView.addArrangedSubview(propertiesLabel)
        stackView.addArrangedSubview(deviceNameLabel)
        stackView.addArrangedSubview(deviceIDLabel)
        stackView.addArrangedSubview(deviceStateLabel)
//        configureIDLabel()
//        configureNameLabel()
//        configureStateLabel()
        configurePropertiesLabel()
    }
    required init?(coder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    func set(device: Device) {
        deviceNameLabel.text = device.name
        deviceStateLabel.text = device.state
        deviceIDLabel.text = device.id
        propertiesLabel.text = """
                                Device: \(device.name)
                                State: \(device.state)
                                ID: \(device.id)
                                """
    }
    
    func configurePropertiesLabel() {
        propertiesLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        propertiesLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        propertiesLabel.numberOfLines = 0
        propertiesLabel.adjustsFontSizeToFitWidth = true
     }
    
    func configureNameLabel() {
        deviceNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        deviceNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        deviceNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        deviceStateLabel.numberOfLines = 0
//        deviceStateLabel.adjustsFontSizeToFitWidth = true
//
//        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
//        deviceNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        deviceNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        deviceNameLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
//        deviceNameLabel.widthAnchor.constraint(equalTo: deviceStateLabel.heightAnchor, multiplier: 16/9).isActive = true
    }
    func configureIDLabel() {
        deviceIDLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        deviceIDLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        deviceStateLabel.numberOfLines = 0
//        deviceStateLabel.adjustsFontSizeToFitWidth = true
//
//        deviceIDLabel.translatesAutoresizingMaskIntoConstraints = false
//        deviceIDLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        deviceIDLabel.leadingAnchor.constraint(equalTo: deviceNameLabel.trailingAnchor).isActive = true
//        deviceIDLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
//        deviceIDLabel.trailingAnchor.constraint(equalTo: deviceNameLabel.trailingAnchor).isActive = true
    }
    func configureStateLabel() {
        deviceStateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        deviceStateLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        deviceStateLabel.numberOfLines = 0
//        deviceStateLabel.adjustsFontSizeToFitWidth = true
//
//        deviceStateLabel.translatesAutoresizingMaskIntoConstraints = false
//        deviceStateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        deviceStateLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        deviceStateLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
//        deviceStateLabel.trailingAnchor.constraint(equalTo: deviceNameLabel.trailingAnchor).isActive = true
    }
}
