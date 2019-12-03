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
    let nc = NotificationCenter.default
    private let bluetoothManager = BluetoothManager.sharedManager
    private let reuseIdentifier = "SettingsCell"
    private let peripheralState = [
        "disconnected",
        "connecting",
        "connected",
        "disconnecting"
    ]
    private var serviceTable : [CBUUID] = []
    private var characteristicTable : [CBUUID] = []
    let service = CBUUID(string: "00000ace-0000-1000-8000-00805f9b34fb")
    let one = CBUUID(string: "0000ace0-0000-1000-8000-00805f9b34fb")
    let two = CBUUID(string: "0000ace1-0000-1000-8000-00805f9b34fb")
    let three = CBUUID(string: "0000ace2-0000-1000-8000-00805f9b34fb")
    let deviceList = CBUUID(string: "0000ace2-0000-1000-8000-00805f9b34fb")

    var delegate : DeviceDetailDelegate?
    var cell : DeviceCell?
    var peripheral : CBPeripheral?
    var characteristics : [CBCharacteristic] = []
    var services : [CBService] = []
    var childDevices : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNotifications()
        configureUI()
        configureTable()
        updateServicesAndCharacteristics()
    }
    
    func configureNotifications() {
        nc.addObserver(forName: BluetoothManager.characteristicUpdated, object: nil, queue: OperationQueue.main) { (notification) in
            let characteristic = notification.userInfo!["characteristic"] as! CBCharacteristic
            let peripheral = notification.userInfo!["peripheral"] as! CBPeripheral
            print(characteristic.descriptors, characteristic.value)
            switch characteristic.uuid {
            case self.deviceList:
                return
            default:
                return
            }
        }
        
    }
    
    func configureUI(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Disconnect", style: .done, target: self, action: #selector(handleDisconnect))
    }
    
    func configureTable(){
        self.serviceTable = [service]
        self.characteristicTable = [one, two, three]
        self.tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        tableView.tableFooterView = UIView()
    }
    
    func updateServicesAndCharacteristics() {
        let services = self.peripheral?.services
        if services != nil {
            for service in services!{
                self.services.append(service)
                for characteristic in service.characteristics! {
                    print(characteristic, characteristic.value)
                    characteristics.append(characteristic)
                }
            }
        }
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
        let services = self.peripheral?.services
        if services != nil {
            for service in services!{
                print(service)
                for characteristic in service.characteristics! {
                    print(characteristic, characteristic.value)
                    characteristics.append(characteristic)
                    let value = characteristic.value ?? nil
                    if value != nil {
                        let data = [UInt8](value!)
                        print(data)
                    }
                    var num = NSInteger(1)
                    let data = NSData(bytes: &num, length: 1)
                    peripheral?.writeValue(data as Data, for: characteristic, type: .withResponse)
                }
            }
        }
    }
    
    func sendData(data: NSData){
        peripheral?.writeValue(data as Data, for: characteristics[0], type: .withResponse)
    }
    
    func refreshChildDevices(){
        var num = NSInteger(1)
        let data = NSData(bytes: &num, length: 1)
        
//        peripheral?.writeValue(data as Data, for: , type: .withResponse)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return 50 }
        switch section {
        case .DeviceInfo:
            return 70
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
            cell.switchControl.isHidden = true
            let nameLabel = UILabel()
            nameLabel.text = "Name: \(peripheral!.name ?? "N/A")"
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(nameLabel)
            nameLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10).isActive = true
            nameLabel.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 16).isActive = true
            nameLabel.font = UIFont.systemFont(ofSize: 16)
            let idLabel = UILabel()
            idLabel.translatesAutoresizingMaskIntoConstraints = false
            idLabel.text = "UUID: \(peripheral!.identifier.uuidString )"
            cell.addSubview(idLabel)
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
            idLabel.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 16).isActive = true
            idLabel.font = UIFont.systemFont(ofSize: 15)
            
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
            case .refreshDeviceList:
                break
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
