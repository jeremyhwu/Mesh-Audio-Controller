//
//  DeviceDetailController.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/14/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import UIKit
import CoreBluetooth

private let reuseIdentifier = "SettingsCell"
private let peripheralState = [
    "disconnected",
    "connecting",
    "connected",
    "disconnecting"
]

class DeviceDetailController: UITableViewController {
    var delegate : DeviceDetailDelegate?
    var cell : DeviceCell?
    var peripheral : CBPeripheral?
    var cells  = [[Device]]()
    var tableData = [[SettingsCell]]()
    
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
            if (deviceInfo?.action != nil){
                guard let action = deviceInfo?.action! else {break}
                self.present(action, animated: true)
            }
        case .Settings:
            let settings = Settings(rawValue: indexPath.row)
            if (settings?.action != nil){
                guard let action = settings?.action! else {break}
                self.present(action, animated: true)
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
