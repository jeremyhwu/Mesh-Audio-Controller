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
}

enum Settings: Int, CaseIterable, SectionType {
    case rename
    case mute
    case getData
    case sendData
    case refreshDeviceList
    
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
        case .sendData: return "Send data"
        case .refreshDeviceList: return "Refresh Child Devices"
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
}

