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
    
    let deviceNameLabel : UILabel = {
        let label = UILabel()
        label.text = "Name goes here"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deviceIdLabel : UILabel = {
        let label = UILabel()
        label.text = "Id goes here"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deviceStateLabel : UILabel = {
        let label = UILabel()
        label.text = "State goes here"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let profileImageDimension: CGFloat = 60
//
//        addSubview(profileImageView)
//        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
//        profileImageView.layer.cornerRadius = profileImageDimension / 2
//
        addSubview(deviceNameLabel)
        deviceNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deviceNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        
        addSubview(deviceIdLabel)
        deviceIdLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        
        addSubview(deviceStateLabel)
        deviceStateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
