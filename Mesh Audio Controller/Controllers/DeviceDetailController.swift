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
    view.backgroundColor = .white
    }

    func configureTable(){
        self.tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 0)
        let infoHeader = DeviceInfoHeader(frame: frame)
        infoHeader.id = self.peripheral?.identifier.uuidString
        infoHeader.state = peripheralState[(self.peripheral?.state.rawValue)!]
        infoHeader.name = self.peripheral?.name
        self.tableView.rowHeight = 60
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
                return 80
            case .Settings:
                return 50
            case .Devices:
                return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
//        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
//
////        switch section {
////        case .DeviceInfo:
////            let social = DeviceInfo(rawValue: indexPath.row)
////            cell.sectionType = social
////        case .Settings:
////            let communications = CommunicationOptions(rawValue: indexPath.row)
////            cell.sectionType = communications
////        case .Devices
////
////        }
//
//        return cell
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        let title = UILabel()
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                          "sectionHeader") as! Header
        view.title.text = SettingsSection(rawValue: section)?.description

        return view
//        title.font = UIFont.boldSystemFont(ofSize: 16)
//        title.text = SettingsSection(rawValue: section)?.description
//        view.addSubview(title)
//        title.translatesAutoresizingMaskIntoConstraints = false
//        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
////        title.topAnchor.constraint(equalTo: super.view.bottomAnchor).isActive = true
//        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         guard let section = SettingsSection(rawValue: section) else { return 0 }
                switch section {
                case .DeviceInfo: return DeviceSettings.allCases.count
                case .Settings:
                    return 4
                case .Devices:
                    return 4
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
}

//
//class DeviceDetailController: UIViewController {
//
//    // MARK: - Properties
//
//    var tableView: UITableView!
//    var deviceInfoHeader: DeviceInfoHeader!
//
//    // MARK: - Init
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//    }
//
//    // MARK: - Helper Functions
//
//    func configureTableView() {
//        tableView = UITableView()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.rowHeight = 60
//
//        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
//        view.addSubview(tableView)
//        tableView.frame = view.frame
//
//        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
//        deviceInfoHeader = DeviceInfoHeader(frame: frame)
//        tableView.tableHeaderView = deviceInfoHeader
//        tableView.tableFooterView = UIView()
//    }
//
//    func configureUI() {
//        configureTableView()
//
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
//        navigationItem.title = "Settings"
//    }
//
//}
//
//extension ViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return SettingsSection.allCases.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        guard let section = SettingsSection(rawValue: section) else { return 0 }
//
//        switch section {
//        case .Social: return SocialOptions.allCases.count
//        case .Communications: return CommunicationOptions.allCases.count
//        }
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
//
//        print("Section is \(section)")
//
//        let title = UILabel()
//        title.font = UIFont.boldSystemFont(ofSize: 16)
//        title.textColor = .white
//        title.text = SettingsSection(rawValue: section)?.description
//        view.addSubview(title)
//        title.translatesAutoresizingMaskIntoConstraints = false
//        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
//
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
//        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
//
//        switch section {
//        case .Social:
//            let social = SocialOptions(rawValue: indexPath.row)
//            cell.sectionType = social
//        case .Communications:
//            let communications = CommunicationOptions(rawValue: indexPath.row)
//            cell.sectionType = communications
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
//
//        switch section {
//        case .Social:
//            print(SocialOptions(rawValue: indexPath.row)?.description)
//        case .Communications:
//            print(CommunicationOptions(rawValue: indexPath.row)?.description)
//        }
//    }
//}
