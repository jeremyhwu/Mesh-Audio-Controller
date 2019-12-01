//
//  BluetoothManager.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/28/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import CoreBluetooth
import UIKit

class BluetoothManager : NSObject {
    static let sharedManager = BluetoothManager() //create a static instance to share manager across views
    
    //UUID variables
    let service1 = CBUUID(string: "C3093770-1A43-4F1C-ABCC-24A448FC6218")
    let service2 = CBUUID(string: "CEEF1D13-633C-4AC4-8B16-BC4D392551AD")
    let testService = CBUUID(string: "bf280f00-af11-41dd-a122-573cdb92b56c")
    let testCharacteristic = CBUUID(string: "9886ca1d-4ad4-41fb-9c85-8aad722b0e47")
    let hello = CBUUID(string: "9FEE1609-4B66-4DCC-87B0-E0DD2415E892")
    let world = CBUUID(string: "4B9A381D-90E4-41DD-AA10-83746A4B5F1F")
    
    //Notifications
    static let scanStarted = NSNotification.Name("SCAN_STARTED")
    static let scanEnded = NSNotification.Name("SCAN_STOPPED")
    static let deviceConnected = NSNotification.Name("CONNECTED_NOTIFICATION")
    
    //Peripherals/characteristic storage
    fileprivate var cbCentralManager: CBCentralManager!
    fileprivate var connectedPeripherals = Set<CBPeripheral>()
    fileprivate var disconnectedPeripherals = Set<CBPeripheral>()
    fileprivate var characteristics = [CBPeripheral:Set<CBCharacteristic>]()
    
    private let queue = DispatchQueue(label: "BTQueue")
    var timer = Timer()
    
    private override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: queue, options: [CBCentralManagerOptionRestoreIdentifierKey: "SharedManager"])
    }
    
    func scan(){
        print("Scanning for devices")
        cbCentralManager.scanForPeripherals(withServices: nil, options: nil)
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            self.stopscan()
        }
    }
    
    func stopscan(){
        self.timer.invalidate()
        cbCentralManager.stopScan()
    }
    
    func sendCompleteNotification(peripheral: CBPeripheral) {
        let nc = NotificationCenter.default
        nc.post(name: BluetoothManager.deviceConnected, object: self, userInfo: ["NAME":peripheral.name ?? "Unknown","ID":peripheral.identifier.uuidString])
    }
    
    func sendScanStartedNotification(peripheral: CBPeripheral) {
        let nc = NotificationCenter.default
        nc.post(name: BluetoothManager.scanStarted, object: nil)
    }
    
    func sendScanEndedNotification(peripheral: CBPeripheral) {
        let nc = NotificationCenter.default
        nc.post(name: BluetoothManager.scanEnded, object: nil)
    }
    
    func sendConnectedNotification(peripheral: CBPeripheral) {
        let nc = NotificationCenter.default
        nc.post(name: BluetoothManager.scanEnded, object: peripheral)
    }
}

extension BluetoothManager : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        case .poweredOn:
            self.scan()
        @unknown default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.disconnectedPeripherals.insert(peripheral)
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral)")
        self.connectedPeripherals.insert(peripheral)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        self.disconnectedPeripherals.remove(peripheral)
        self.sendConnectedNotification(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.connectedPeripherals.remove(peripheral)
        
        if let error = error {
            print("Disconnected from \(peripheral) with error: \(error)")
            
        } else {
            print("Disconnected from \(peripheral)")
        }
        //
        //        self.connectedPeripherals.remove(peripheral)
        //        self.characteristics[peripheral] = nil
        //
        //        if  self.targetPeripherals.contains(peripheral) && reconnectMode {
        //
        //            log?.info("Initiating reconnection to \(peripheral)")
        //            central.connect(peripheral, options: nil)
        //        } else if !reconnectMode {
        //            self.stopScan()
        //            self.startScan()
        //        }
        //
        //        self.sendDisconnectionNotification()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //
        //        if let error = error {
        //            log?.error("Failed to connect with error:\(error)")
        //        } else {
        //            log?.error("Failed to connect")
        //        }
        //
        //        self.sendDisconnectionNotification()
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        //        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
        //
        //            for peripheral in peripherals {
        //
        //                log?.info("Restored peripheral \(peripheral)")
        //                if peripheral.state == .connected {
        //                    self.targetPeripherals.insert(peripheral)
        //                    self.connectedPeripherals.insert(peripheral)
        //                    self.sendConnectionNotification()
        //                }
        //            }
        //        }
        //
    }
}

extension BluetoothManager : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service) //discover all characteristics for now
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //        log?.info("Discovered characteristics")
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            self.characteristics[peripheral]?.insert(characteristic) //keep track of all characteristics in set
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("updated characterstic \(characteristic). New value: \(characteristic.value)")
        //        if let data = characteristic.value {
        //            var values = [UInt8](repeating:0, count:data.count)
        //            data.copyBytes(to: &values, count: data.count)
        //            print("\(values[0])")
        //        }
    }
    
}
