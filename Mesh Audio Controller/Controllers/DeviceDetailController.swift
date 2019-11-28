//
//  DeviceDetailController.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/14/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceDetailController: UITableViewController, CBPeripheralDelegate {
    private let reuseIdentifier = "SettingsCell"
    private let peripheralState = [
        "disconnected",
        "connecting",
        "connected",
        "disconnecting"
    ]
    private var serviceTable : [CBUUID] = []
    private var characteristicTable : [CBUUID] = []
    let service1 = CBUUID(string: "C3093770-1A43-4F1C-ABCC-24A448FC6218")
    let service2 = CBUUID(string: "CEEF1D13-633C-4AC4-8B16-BC4D392551AD")
    let testService = CBUUID(string: "3f403394-0000-1000-8000-00805f9b34fb")
    let testCharacteristic = CBUUID(string: "3f40350c-0000-1000-8000-00805f9b34fb")
    let hello = CBUUID(string: "9FEE1609-4B66-4DCC-87B0-E0DD2415E892")
    let world = CBUUID(string: "4B9A381D-90E4-41DD-AA10-83746A4B5F1F")
    var delegate : DeviceDetailDelegate?
    var cell : DeviceCell?
    var peripheral : CBPeripheral?
    var characteristics : [CBCharacteristic]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTable()
    }
    
    func configureUI(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Disconnect", style: .done, target: self, action: #selector(handleDisconnect))
    }
    
    func configureTable(){
        self.serviceTable = [service1, service2, testService]
        self.characteristicTable = [hello, world, testCharacteristic]
        self.tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        let infoHeader = DeviceInfoHeader()
        infoHeader.id = self.peripheral?.identifier.uuidString
        infoHeader.state = peripheralState[(self.peripheral?.state.rawValue)!]
        infoHeader.name = self.peripheral?.name
        self.tableView.tableHeaderView = infoHeader
        tableView.tableFooterView = UIView()
    }
    
    @objc func handleDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDisconnect() {
        let alert = UIAlertController(title: "Disconnect?", message: "Disconnect from this device?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.delegate?.disconnect(peripheral: self.peripheral!, controller: self)
        }))
        self.present(alert, animated: true)
    }
    
    //GATT Services
    func getData() {
        peripheral?.discoverServices(nil)
        guard let services = peripheral?.services else { return }
        for service in services {
            print(service.uuid)
//            if self.serviceTable.contains(service.uuid){
                peripheral?.discoverCharacteristics(nil, for: service)
                guard let characteristics = service.characteristics else { return }
                for characterstic in characteristics {
                    print("here")
                    peripheral?.setNotifyValue(true, for: characterstic)
                    peripheral?.discoverDescriptors(for: characterstic)
                    peripheral?.readValue(for: characterstic)
                    print(characterstic.value)
                    print(characterstic.descriptors)
                }
//            }
        }
    }
    func sendData(data: NSData){
        //        peripheral?.writeValue(data: data, for: CBDescriptor())
    }
        
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic.value as Any)
        switch characteristic.uuid {
        case hello:
            print("hello: uuid: \(characteristic.uuid)")
        case world:
            print("world: uuid: \(characteristic.uuid)")
        default:
            break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Notification has started
        print("didUpdateNotificationStateFor")
        if (characteristic.isNotifying) {
            print("Notification began on \(characteristic)");
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("didUpdateValueFor")
        print(descriptor)
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueFor")
        print(characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
          print("characteristic discovered")
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return 50 }
        switch section {
        case .DeviceInfo:
            return 60
        case .Settings:
            return 50
        case .Devices:
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .DeviceInfo:
            let deviceInfo = DeviceInfo(rawValue: indexPath.row)
            if deviceInfo!.containsSwitch {
                cell.selectionStyle = .none
            }
            cell.sectionType = deviceInfo
        case .Settings:
            let settings = Settings(rawValue: indexPath.row)
            if settings!.containsSwitch {
                cell.selectionStyle = .none
            }
            cell.sectionType = settings
        case .Devices:
            let devices = Devices(rawValue: indexPath.row)
            if devices!.containsSwitch {
                cell.selectionStyle = .none
            }
            cell.sectionType = devices
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        switch section {
        case .DeviceInfo:
            let deviceInfo = DeviceInfo(rawValue: indexPath.row)
        case .Settings:
            let settings = Settings(rawValue: indexPath.row)
            switch settings {
            case .rename:
                let alert = UIAlertController(title: "Rename this device?", message: nil, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter a new name"
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: nil))
                self.present(alert, animated: true)
            case .mute:
                return
            case .getData:
                let alert = UIAlertController(title: "Grab new data?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) -> Void in
                    self.getData()
                }))
                self.present(alert, animated: true)
            case .none:
                return
            case .some(.sendData):
                let alert = UIAlertController(title: "Send new data?", message: nil, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter data"
                }
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) -> Void in
                    let textField = alert.textFields![0]
                    let text = textField.text?.data(using: .utf8)
                    if text != nil {
                        self.sendData(data: NSData(data: text!))
                    }
                }))
                self.present(alert, animated: true)
            }
        case .Devices:
            let devices = Devices(rawValue: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            "sectionHeader") as! Header
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        view.backgroundView = backgroundView
        view.title.text = SettingsSection(rawValue: section)?.description
        
        return view
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        switch section {
        case .DeviceInfo:
            return DeviceInfo.allCases.count
        case .Settings:
            return Settings.allCases.count
        case .Devices:
            return Devices.allCases.count
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
}
