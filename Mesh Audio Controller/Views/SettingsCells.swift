//
//  SettingsCell.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//
import UIKit

/*
 Collection of classes that represent table cells in the device detail view. Each section
 of the table contains varying types of data so they each need their own custom table cell.
 */

class DeviceInfoCell: UITableViewCell {
    var nameLabel = UILabel()
    var idLabel = UILabel()
    var servicesLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 18))
        nameLabel.adjustsFontForContentSizeCategory = true
        addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(idLabel)
        idLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        idLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        
        servicesLabel.translatesAutoresizingMaskIntoConstraints = false
        servicesLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(servicesLabel)
        servicesLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        servicesLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        servicesLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 10).isActive = true
        servicesLabel.numberOfLines = 0
        
        self.bottomAnchor.constraint(equalTo: servicesLabel.bottomAnchor, constant: 10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class CharacteristicsCell : UITableViewCell {
    var uuidLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        uuidLabel.translatesAutoresizingMaskIntoConstraints = false
        uuidLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 18))
        uuidLabel.adjustsFontForContentSizeCategory = true
        addSubview(uuidLabel)
        uuidLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        uuidLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        uuidLabel.font = UIFont.systemFont(ofSize: 16)
        
        self.bottomAnchor.constraint(equalTo: uuidLabel.bottomAnchor, constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsCell: UITableViewCell {
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleSwitchAction(sender: UISwitch) {
        if sender.isOn {
            print("Turned on")
        } else {
            print("Turned off")
        }
    }
}

class DevicesCell : UITableViewCell {
    var childLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        childLabel.translatesAutoresizingMaskIntoConstraints = false
        childLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 18))
        childLabel.adjustsFontForContentSizeCategory = true
        addSubview(childLabel)
        childLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        childLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        childLabel.font = UIFont.systemFont(ofSize: 16)
        self.bottomAnchor.constraint(equalTo: childLabel.bottomAnchor, constant: 10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
