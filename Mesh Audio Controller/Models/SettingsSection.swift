//
//  SettingsSection.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//
import UIKit
import CoreBluetooth

/*
 These enumerables allow the table cells in the device detail controller to be dynamic.
 They contain one or more cases which are returned based on the index of the selected cell.
 */
protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}


enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case DeviceInfo
    case Characteristics
    case Settings
    case Devices
    
    var description: String {
        switch self {
        case .DeviceInfo: return "Device Info"
        case .Characteristics: return "Characteristics"
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
        case .rename: return "Rename Device (Root)"
        case .mute: return "Mute Device"
        case .getData: return "Update Characteristics"
        case .sendData: return "Send Custom Data"
        }
    }
}

enum Devices: Int, CaseIterable, SectionType {
    case refreshDevices
    
    var containsSwitch: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .refreshDevices: return "Refresh Device List"
        }
    }
}

