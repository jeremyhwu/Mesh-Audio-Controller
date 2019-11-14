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
        let stackView = UIStackView()
        let container = UIView()
        container.addSubview(stackView)
        addSubview(container)
        stackView.addArrangedSubview(propertiesLabel)
        stackView.addArrangedSubview(deviceNameLabel)
        stackView.addArrangedSubview(deviceIDLabel)
        stackView.addArrangedSubview(deviceStateLabel)
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
        propertiesLabel.text = """
                                \(device.name)
                                """
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
        
        deviceIDLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        deviceIDLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        deviceNameLabel.leadingAnchor.constraint(equalTo: deviceIDLabel.leadingAnchor).isActive = true
        deviceNameLabel.trailingAnchor.constraint(equalTo: deviceIDLabel.trailingAnchor).isActive = true
        
        deviceIDLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: contentView.layoutMarginsGuide.topAnchor, multiplier: 1).isActive = true

        self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: deviceNameLabel.lastBaselineAnchor, multiplier: 1).isActive = true

        deviceNameLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: deviceIDLabel.lastBaselineAnchor, multiplier: 1).isActive = true

        
        
        
//        guard let palatino = UIFont(name: "Palatino", size: 18) else {
//                  fatalError("""
//                      Failed to load the "Palatino" font.
//                      Since this font is included with all versions of iOS that support Dynamic Type, verify that the spelling and casing is correct.
//                      """
//                  )
//              }
//        propertiesLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: palatino)
//        propertiesLabel.adjustsFontForContentSizeCategory = true
//
//        propertiesLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
//        propertiesLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
//
//        propertiesLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: contentView.layoutMarginsGuide.topAnchor, multiplier: 1).isActive = true
//        propertiesLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        propertiesLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        propertiesLabel.numberOfLines = 3
//        propertiesLabel.adjustsFontSizeToFitWidth = true
//        propertiesLabel.preferredMaxLayoutWidth = self.frame.size.width
     }
}
