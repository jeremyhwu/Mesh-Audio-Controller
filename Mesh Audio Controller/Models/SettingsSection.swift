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

enum DeviceSettings: Int, CaseIterable, SectionType {
    case rename
    
    var containsSwitch: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .rename: return "Rename Device"
    }
    }
}

//
//enum SocialOptions: Int, CaseIterable, SectionType {
//    case editProfile
//    case logout
//    
//    var containsSwitch: Bool { return false }
//    
//    var description: String {
//        switch self {
//        case .editProfile: return "Edit Profile"
//        case .logout: return "Log Out"
//        }
//    }
//}
//
//enum CommunicationOptions: Int, CaseIterable, SectionType {
//    case notifications
//    case email
//    case reportCrashes
//    
//    var containsSwitch: Bool {
//        switch self {
//        case .notifications: return true
//        case .email: return true
//        case .reportCrashes: return true
//        }
//    }
//    
//    var description: String {
//        switch self {
//        case .notifications: return "Notifications"
//        case .email: return "Email"
//        case .reportCrashes: return "Report Crashes"
//        }
//    }
//}
