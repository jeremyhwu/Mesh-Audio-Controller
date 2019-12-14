//
//  BluetoothManager.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/28/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import CoreBluetooth
import UIKit

/*
 Bluetooth manager that contains a static instance of itself. This allows the same bluetooth manager
 and peripheral list to be shared across all views. This class implements the CBPeripheral and CBCentralManager protocols
 and handles connecting/disconnecting from peripherals as well as writing/receiving data that is being
 advertised by connected peripherals.
 */
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
    static let deviceDisconnected = NSNotification.Name("DISCONNECTED_NOTIFICATION")
    static let btDisabled = NSNotification.Name("BT_DISABLED")
    static let characteristicUpdated = NSNotification.Name("CHARACTERISTIC_UPDATED")
    static let wroteValue = NSNotification.Name("WROTE_VALUE")
    
    //Peripherals/characteristic storage
    var cbCentralManager: CBCentralManager!
    var connectedPeripherals = Set<CBPeripheral>()
    var disconnectedPeripherals = Set<CBPeripheral>()
    var characteristics = [CBPeripheral:Set<CBCharacteristic>]()
    
    private let queue = DispatchQueue(label: "BTQueue")
    private let nc = NotificationCenter.default
    var timer = Timer()
    
    private override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: queue, options: [CBCentralManagerOptionRestoreIdentifierKey: "SharedManager"])
        
    }
    
    func connect(peripheral: CBPeripheral) {
        peripheral.delegate = self
        self.cbCentralManager.connect(peripheral, options: nil)
    }
    
    func disconnect(peripheral: CBPeripheral) {
        self.cbCentralManager.cancelPeripheralConnection(peripheral)
    }
    
    func scan() {
        print("Scanning for devices")
        cbCentralManager.scanForPeripherals(withServices: nil, options: nil)
        self.sendScanStartedNotification()
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            self.stopscan()
        }
    }
    
    func stopscan() {
        self.sendScanEndedNotification()
        self.timer.invalidate()
        cbCentralManager.stopScan()
    }
    
    func refresh() {
        for peripheral in disconnectedPeripherals {
            characteristics.removeValue(forKey: peripheral)
        }
        disconnectedPeripherals = Set<CBPeripheral>()
        self.scan()
    }
    
    func sendCompleteNotification(peripheral: CBPeripheral) {
        nc.post(name: BluetoothManager.deviceConnected, object: self, userInfo: ["NAME":peripheral.name ?? "Unknown","ID":peripheral.identifier.uuidString])
    }
    
    func sendScanStartedNotification() {
        nc.post(name: BluetoothManager.scanStarted, object: nil)
    }
    
    func sendScanEndedNotification() {
        nc.post(name: BluetoothManager.scanEnded, object: nil)
    }
    
    func sendConnectedNotification(peripheral: CBPeripheral) {
        nc.post(name: BluetoothManager.deviceConnected, object: self, userInfo: ["peripheral":peripheral])
    }
}

extension BluetoothManager : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            break
        default:
            let nc = NotificationCenter.default
            nc.post(name: BluetoothManager.btDisabled, object: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            self.disconnectedPeripherals.insert(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name!)")
        self.connectedPeripherals.insert(peripheral)
        peripheral.discoverServices(nil)
        self.disconnectedPeripherals.remove(peripheral)
        self.sendConnectedNotification(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected from \(peripheral.name!)")
        self.connectedPeripherals.remove(peripheral)
        nc.post(name: BluetoothManager.deviceDisconnected, object: self, userInfo: ["peripheral":peripheral])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect")
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                if peripheral.state == .connected {
                    self.disconnectedPeripherals.insert(peripheral)
                }
            }
        }
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
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            self.characteristics[peripheral]?.insert(characteristic) // keep track of all characteristics in set
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic) // Subscribe to all characteristics
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        nc.post(name: BluetoothManager.characteristicUpdated, object: self, userInfo: ["peripheral":peripheral, "characteristic":characteristic])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.value != nil {
            let data = [UInt8](characteristic.value!)
            print("Wrote \(data) to \(characteristic.uuid)")
        }
        nc.post(name: BluetoothManager.wroteValue, object: self, userInfo: ["peripheral":peripheral, "characteristic":characteristic])
    }
}
