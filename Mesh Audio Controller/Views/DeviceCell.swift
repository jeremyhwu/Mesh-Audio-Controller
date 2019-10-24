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
    
    func configureNameLabel() {
        deviceStateLabel.numberOfLines = 0
        deviceStateLabel.adjustsFontSizeToFitWidth = true
    }
    func configureIDLabel() {
        deviceStateLabel.numberOfLines = 0
        deviceStateLabel.adjustsFontSizeToFitWidth = true
    }
    func configureStateLabel() {
        deviceStateLabel.numberOfLines = 0
        deviceStateLabel.adjustsFontSizeToFitWidth = true
    }
}
