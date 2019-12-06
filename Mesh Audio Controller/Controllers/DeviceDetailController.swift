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
    var childDevices : [String] = ["Device 1", "Device 2", "Device 3", "Device 4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNotifications()
        configureUI()
        configureTable()
        updateServicesAndCharacteristics()
    }
    
    func configureNotifications() {
        nc.addObserver(forName: BluetoothManager.characteristicUpdated, object: nil, queue: OperationQueue.main) { (notification) in
            DispatchQueue.main.async {
                let characteristic = notification.userInfo!["characteristic"] as! CBCharacteristic
                print("Characteristic updated: \(characteristic.uuid)")
                switch characteristic.uuid {
                case self.deviceList:
                    return
                default:
                    return
                }
            }
        }
        nc.addObserver(forName: BluetoothManager.wroteValue, object: nil, queue: OperationQueue.main) { (notification) in
            DispatchQueue.main.async {
                let characteristic = notification.userInfo!["characteristic"] as! CBCharacteristic
                let data = [UInt8](characteristic.value!)
                let alert = UIAlertController(title: "Succesfully wrote value \(data) to characteristic: \(characteristic.uuid)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func configureUI(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Disconnect", style: .done, target: self, action: #selector(handleDisconnect))
    }
    
    func configureTable(){
        self.tableView.insetsContentViewsToSafeArea = true
        self.serviceTable = [service]
        self.characteristicTable = [one, two, three]
        self.tableView.register(SettingsCell.self, forCellReuseIdentifier: "settingsIdentifier")
        self.tableView.register(DeviceInfoCell.self, forCellReuseIdentifier: "devicesInfoIdentifier")
        self.tableView.register(CharacteristicsCell.self, forCellReuseIdentifier: "characteristicsIdentifier")
        self.tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        self.tableView.register(DevicesCell.self, forCellReuseIdentifier: "devicesIdentifier")
        
        tableView.tableFooterView = UIView()
    }
    
    func updateServicesAndCharacteristics() {
        let services = self.peripheral?.services
        if services != nil {
            for service in services!{
                self.services.append(service)
                if service.characteristics != nil{
                    for characteristic in service.characteristics! {
                        characteristics.append(characteristic)
                    }
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
        characteristics = []
        let services = self.peripheral?.services
        if services != nil {
            for service in services!{
                for characteristic in service.characteristics! {
                    peripheral?.readValue(for: characteristic) // read the most current value from the peripheral
                    characteristics.append(characteristic)
                    let value = characteristic.value ?? nil
                    if value != nil {
                        let data = [UInt8](value!)
                        print("Data for \(characteristic.uuid):", data)
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func sendData(data: NSData, characteristic: CBCharacteristic?){
        if characteristic != nil {
            peripheral?.writeValue(data as Data, for: characteristic!, type: .withResponse)
        }
        else{
            let alert = UIAlertController(title: "Invalid characteristic entered", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    
    func refreshChildDevices(){
        var num = NSInteger(1)
        let data = NSData(bytes: &num, length: 1)
        
        //        peripheral?.writeValue(data as Data, for: , type: .withResponse)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .DeviceInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "devicesInfoIdentifier", for: indexPath) as! DeviceInfoCell
            cell.nameLabel.text = "Name: \(peripheral!.name ?? "N/A")"
            cell.idLabel.text = "UUID: \(peripheral!.identifier.uuidString )"
            let serviceNames = services.map{$0.uuid}
            cell.servicesLabel.text = "Services: \(serviceNames)"
            return cell
            
        case .Characteristics:
            let cell = tableView.dequeueReusableCell(withIdentifier: "characteristicsIdentifier", for: indexPath) as! CharacteristicsCell
            let characteristic = characteristics[indexPath.row]
            cell.uuidLabel.text = "\(characteristic.uuid)"
            return cell
            
        case .Settings:
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsIdentifier", for: indexPath) as! SettingsCell
            let settings = Settings(rawValue: indexPath.row)
            if settings!.containsSwitch {
                cell.selectionStyle = .none
                cell.switchControl.isHidden = true
            }
            cell.sectionType = settings
            return cell
        case .Devices:
            let cell = tableView.dequeueReusableCell(withIdentifier: "devicesIdentifier", for: indexPath) as! DevicesCell
            let row = indexPath.row
            if row < Devices.allCases.count{
                let devices = Devices(rawValue: indexPath.row)
                cell.sectionType = devices
            }
            else{
                let childName = childDevices[row - Devices.allCases.count]
                cell.childLabel.text = childName
            }
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        switch section {
        case .DeviceInfo:
            break
        case .Characteristics:
            let characteristic = characteristics[indexPath.row]
            let alert = UIAlertController(title: "Write to \(characteristic.uuid)?", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Enter data to write"
            }
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) -> Void in
                let dataField = alert.textFields![0]
                let text = dataField.text!
                if text != "" {
                    let data = text.data(using: .utf8)
                    self.sendData(data: NSData(data: data!), characteristic: characteristic)
                }
                else{
                    alert.dismiss(animated: true, completion: nil)
                    let warning = UIAlertController(title: "Data cannot be empty", message: nil, preferredStyle: .alert)
                    warning.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(warning, animated: true)
                }
            }))
            self.present(alert, animated: true)
        case .Settings:
            let settings = Settings(rawValue: indexPath.row)
            switch settings {
            case .rename:
                let alert = UIAlertController(title: "Rename \(peripheral!.name ?? "N/A")?", message: nil, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter a new name"
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: nil))
                self.present(alert, animated: true)
            case .mute:
                return
            case .getData:
                let alert = UIAlertController(title: "Retrieve Updated Characteristics from Peripheral?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) -> Void in
                    self.getData()
                }))
                self.present(alert, animated: true)
            case .none:
                return
            case .some(.sendData):
                let alert = UIAlertController(title: "Send custom data?", message: nil, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter data"
                }
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter Characteristic UUID"
                }
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) -> Void in
                    let dataField = alert.textFields![0]
                    let text = dataField.text!
                    let characteristicField = UUID(uuidString: alert.textFields![1].text!) //create a new UUID with the field's data
                    if characteristicField != nil && text != "" {
                        let characteristicField = CBUUID(string: alert.textFields![1].text!)
                        let characteristic = self.characteristics.first(where: {$0.uuid.uuidString == characteristicField.uuidString})
                        let data = text.data(using: .utf8)
                        self.sendData(data: NSData(data: data!), characteristic: characteristic)
                    }
                    else{
                        alert.dismiss(animated: true, completion: nil)
                        let warning = UIAlertController(title: "Invalid UUID Entered", message: nil, preferredStyle: .alert)
                        warning.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(warning, animated: true)
                    }
                }))
                self.present(alert, animated: true)
            }
        case .Devices:
            let row = indexPath.row
            if row < Devices.allCases.count{
                let devices = Devices(rawValue: indexPath.row)
                switch devices {
                case .refreshDevices:
                    let alert = UIAlertController(title: "Refresh child device list?", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) -> Void in
                        // Todo: logic for refreshing device list
                    }))
                    self.present(alert, animated: true)
                default:
                    break
                }
            }
            else{
                let childName = childDevices[row - Devices.allCases.count]
                let alert = UIAlertController(title: "Rename \(childName)?", message: nil, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter a new name"
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: nil))
                self.present(alert, animated: true)
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
        case .Characteristics:
            return characteristics.count
        case .Settings:
            return Settings.allCases.count
        case .Devices:
            return Devices.allCases.count + childDevices.count
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
}
