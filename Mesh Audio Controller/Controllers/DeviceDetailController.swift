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
    private let serviceTable = [
        CBUUID(string: "0x180D"),
        CBUUID(string: "0x180D")
    ]
    
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
            if self.serviceTable.contains(service.uuid){
                peripheral?.discoverCharacteristics(nil, for: service)
                guard let characteristics = service.characteristics else { return }
                for characterstic in characteristics {
                    peripheral?.discoverDescriptors(for: characterstic)
                    peripheral?.setNotifyValue(true, for: characterstic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let alert = UIAlertController(title: "Data received", message: "\(String(describing: characteristic.value))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
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
        let cell = self.tableView.cellForRow(at: indexPath)
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        switch section {
        case .DeviceInfo:
            let deviceInfo = DeviceInfo(rawValue: indexPath.row)
            if (deviceInfo?.action != nil){
                guard let action = deviceInfo?.action! else {break}
                self.present(action, animated: true)
            }
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
            }
        case .Devices:
            let devices = Devices(rawValue: indexPath.row)
            if (devices?.action != nil){
                guard let action = devices?.action! else {break}
                self.present(action, animated: true)
            }
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
