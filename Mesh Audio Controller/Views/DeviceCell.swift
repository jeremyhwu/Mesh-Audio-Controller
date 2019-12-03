//
//  DeviceCell.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 10/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceCell: UITableViewCell {
    var deviceNameLabel = UILabel()
    var deviceIDLabel = UILabel()
    var deviceStateLabel = UILabel()
    var propertiesLabel = UILabel()
    var stackView : UIStackView?
    var name : String
    var id : String
    var peripheral : CBPeripheral?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.name = ""
        self.id = ""
        self.peripheral = nil
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(deviceNameLabel)
        configureLabels()
    }
    required init?(coder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    func set(device: Device) {
        name = device.name
        id = device.id
        peripheral = device.peripheral
        deviceIDLabel.text = "ID: \(id)"
        deviceNameLabel.text = "\(name)"
    }
    
    func configureLabels() {
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.adjustsFontForContentSizeCategory = true
        deviceNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deviceNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
    }
}
