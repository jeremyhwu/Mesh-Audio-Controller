//
//  SettingsSection.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

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
        return false
    }
    
    var description: String {
        switch self {
        case .info: return "Info"
    }
    }
}

enum Settings: Int, CaseIterable, SectionType {
    case rename
    case mute
    
    var containsSwitch: Bool {
        return true
    }
    
    var description: String {
        switch self {
        case .rename: return "Rename Device"
        case .mute: return "Mute Device"
    }
    }
}

enum Devices: Int, CaseIterable, SectionType {
    case addDevice
    case removeDevice
    
    var containsSwitch: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .addDevice: return "Add Device"
        case .removeDevice: return "Remove Device"
    }
    }
}

