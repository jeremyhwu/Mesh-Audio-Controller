//
//  SettingsSection.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//
import UIKit
import CoreBluetooth

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case DeviceInfo
    case Settings
    case Devices
    
    var description: String {
        switch self {
        case .DeviceInfo: return "Device Info"
        case .Settings: return "Settings"
        case .Devices: return "Child Devices"
        }
    }
}

enum DeviceInfo: Int, CaseIterable, SectionType {
    case info
    
    var containsSwitch: Bool {
        switch self {
        default:
            return false
        }
    }
    var description: String {
        switch self {
        case .info: return ""
        }
    }
    var action: UIAlertController? {
        switch self {
        default:
            return nil
        }
    }
}

enum Settings: Int, CaseIterable, SectionType {
    case rename
    case mute
    case getData
    
    var containsSwitch: Bool {
        switch self {
        case .mute:
            return true
        default:
            return false
        }
    }
    var description: String {
        switch self {
        case .rename: return "Rename Device"
        case .mute: return "Mute Device"
        case .getData: return "Grab new data"
        }
    }
    var action: UIAlertController? {
        switch self {
        case .rename:
            let alert = UIAlertController(title: "Rename this device?", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Enter a new name"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: nil))
            return alert
        case .getData:
            let alert = UIAlertController(title: "Get data?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
            return alert
        default:
            return nil
        }
    }
}

enum Devices: Int, CaseIterable, SectionType {
    case addDevice
    case removeDevice
    case device
    
    var containsSwitch: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .addDevice: return "Add Device"
        case .removeDevice: return "Remove Device"
        case .device: return ""
        }
    }
    var action: UIAlertController? {
        switch self {
        case .addDevice:
            let alert = UIAlertController(title: "Add a new child device?", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Enter a new name"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: nil))
            return alert
        case .removeDevice:
            let alert = UIAlertController(title: "Remove a child device?", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Enter a new name"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: nil))
            return alert
        default:
            return nil
        }
    }
}

