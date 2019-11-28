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
        deviceIDLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        deviceIDLabel.adjustsFontForContentSizeCategory = true
        
        guard let palatino = UIFont(name: "Palatino", size: 18) else {
            fatalError("""
                Failed to load the "Palatino" font.
                Since this font is included with all versions of iOS that support Dynamic Type, verify that the spelling and casing is correct.
                """
            )
        }
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: palatino)
        deviceNameLabel.adjustsFontForContentSizeCategory = true
        deviceNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deviceNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
    }
}
