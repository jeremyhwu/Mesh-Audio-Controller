//
//  DeviceInfoHeader.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import UIKit

class DeviceInfoHeader: UIView {
    var name : String?
    var id : String?
    var state : String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let deviceNameLabel = UILabel()
        deviceNameLabel.text = "Name: \(String(describing: self.name))"
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let deviceIdLabel = UILabel()
        deviceIdLabel.text = "ID: \(String(describing: self.id))"
        deviceIdLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let deviceStateLabel = UILabel()
        deviceStateLabel.text = "State: \(String(describing: self.state))"
        deviceStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(deviceNameLabel)
        deviceNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deviceNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        
        addSubview(deviceIdLabel)
        deviceIdLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        deviceIdLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 15).isActive = true
        
        addSubview(deviceStateLabel)
        deviceStateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        deviceStateLabel.topAnchor.constraint(equalTo: deviceIdLabel.bottomAnchor, constant: 15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
