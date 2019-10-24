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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(deviceNameLabel)
        addSubview(deviceIDLabel)
        addSubview(deviceStateLabel)
        configureIDLabel()
        configureNameLabel()
        configureStateLabel()
    }
    required init?(coder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    func set(device: Device) {
        deviceNameLabel.text = device.name
        deviceStateLabel.text = device.state
        deviceIDLabel.text = device.id
    }
    
    func configureNameLabel() {
//        deviceStateLabel.numberOfLines = 3
        
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deviceNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        deviceNameLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        deviceNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    func configureIDLabel() {
//        deviceStateLabel.numberOfLines = 3
        
        deviceIDLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceIDLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deviceIDLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        deviceIDLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        deviceIDLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    func configureStateLabel() {
//        deviceStateLabel.numberOfLines = 3
        
        deviceStateLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceStateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deviceStateLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        deviceStateLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        deviceStateLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
