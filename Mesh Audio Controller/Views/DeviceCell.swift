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
    var name : String
    var id : String
    var state : String
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.name = ""
        self.state = ""
        self.id = ""
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stackView = UIStackView()
        addSubview(stackView)
        stackView.addArrangedSubview(propertiesLabel)
        stackView.addArrangedSubview(deviceNameLabel)
        stackView.addArrangedSubview(deviceIDLabel)
        stackView.addArrangedSubview(deviceStateLabel)
        configurePropertiesLabel()
    }
    required init?(coder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    func set(device: Device) {
        name = device.name
        id = device.id
        state = device.state
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
        propertiesLabel.preferredMaxLayoutWidth = self.frame.size.width
     }
}
