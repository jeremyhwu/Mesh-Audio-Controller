//
//  Device.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 10/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import UIKit
import CoreBluetooth

struct Device {
    var name : String
    var id : String
    var state : String
    var peripheral : CBPeripheral
}

