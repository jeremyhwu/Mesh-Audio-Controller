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
        self.tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .DeviceInfo:
            cell.switchControl.isHidden = true
            
            let nameLabel = UILabel()
            nameLabel.text = "Name: \(peripheral!.name ?? "N/A")"
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 18))
            nameLabel.adjustsFontForContentSizeCategory = true
            cell.addSubview(nameLabel)
            nameLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10).isActive = true
            nameLabel.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 10).isActive = true
            nameLabel.font = UIFont.systemFont(ofSize: 14)
            
            let idLabel = UILabel()
            idLabel.translatesAutoresizingMaskIntoConstraints = false
            idLabel.text = "UUID: \(peripheral!.identifier.uuidString )"
            idLabel.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(idLabel)
            idLabel.leadingAnchor.constraint(equalTo:  cell.leadingAnchor, constant: 10).isActive = true
            idLabel.trailingAnchor.constraint(equalTo:  cell.trailingAnchor).isActive = true
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
            
            let servicesLabel = UILabel()
            servicesLabel.translatesAutoresizingMaskIntoConstraints = false
            let serviceNames = services.map{$0.uuid}
            servicesLabel.text = "Services: \(serviceNames)"
            servicesLabel.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(servicesLabel)
            servicesLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10).isActive = true
            servicesLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            servicesLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 10).isActive = true
            servicesLabel.numberOfLines = 0
            
            let characteristicsLabel = UILabel()
            characteristicsLabel.translatesAutoresizingMaskIntoConstraints = false
            let characteristicNames = characteristics.map{$0.uuid}
            characteristicsLabel.text = "Characteristics: \(characteristicNames)"
            characteristicsLabel.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(characteristicsLabel)
            characteristicsLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10).isActive = true
            characteristicsLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            characteristicsLabel.topAnchor.constraint(equalTo: servicesLabel.bottomAnchor, constant: 10).isActive = true
            characteristicsLabel.numberOfLines = 0
            
            cell.bottomAnchor.constraint(equalTo: characteristicsLabel.bottomAnchor, constant: 10).isActive = true
                
        case .Settings:
            let settings = Settings(rawValue: indexPath.row)
            if settings!.containsSwitch {
                cell.selectionStyle = .none
            }
            cell.sectionType = settings
        case .Devices:
            let row = indexPath.row
            if row < Devices.allCases.count{
                let devices = Devices(rawValue: indexPath.row)
                if devices!.containsSwitch {
                    cell.selectionStyle = .none
                }
                cell.sectionType = devices
            }
            else{
                cell.switchControl.isHidden = true
                let childName = childDevices[row - Devices.allCases.count]
                let childLabel = UILabel()
                childLabel.text = childName
                childLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(childLabel)
                childLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
                childLabel.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 14).isActive = true
            }
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
                let alert = UIAlertController(title: "Retrieve new data from the peripheral?", message: nil, preferredStyle: .alert)
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
                    textField.placeholder = "Enter Characteristic"
                }
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) -> Void in
                    let dataField = alert.textFields![0]
                    let text = dataField.text?.data(using: .utf8)
                    let characteristicField = alert.textFields![1].text!
                    for char in self.characteristics{
                        print(char.uuid)
                    }
                    let characteristic = self.characteristics.first(where: {$0.uuid.uuidString == characteristicField})
                    if text != nil && characteristic != nil{
                        self.sendData(data: NSData(data: text!), characteristic: characteristic)
                    }
                    else if text != nil {
                        self.sendData(data: NSData(data: text!), characteristic: self.characteristics[0])
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
