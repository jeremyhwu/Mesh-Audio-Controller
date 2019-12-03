//
//  DevicesViewController.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 10/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol DeviceDetailDelegate {
    func updateCells(cell: DeviceCell)
    func disconnect(peripheral: CBPeripheral, controller: DeviceDetailController)
}

class DevicesViewController: UIViewController {
    private let bluetoothManager = BluetoothManager.sharedManager
    let nc = NotificationCenter.default
    
    var tableView = UITableView()
    var dataSource : UITableViewDataSource?
    var timer = Timer()
    var cells = [[Device]]()
    var refreshControl = UIRefreshControl()
    let sections = [
        "Connected",
        "Disconnected"
    ]
    let connected = 0
    let disconnected = 1
    private let peripheralState = [
        "disconnected",
        "connecting",
        "connected",
        "disconnecting"
    ]
    
    enum TableSection : Int {
        case action = 0, Disconnected
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNotifications()
        configureTableView()
        configureRefreshControl()
        configureVars()
        bluetoothManager.scan()
    }
    
    func configureNotifications() {
        nc.addObserver(forName: BluetoothManager.deviceConnected, object: nil, queue: OperationQueue.main) { (notification) in
            let peripheral = notification.userInfo!["peripheral"] as! CBPeripheral
            self.deviceConnected(peripheral: peripheral)
        }
        nc.addObserver(forName: BluetoothManager.deviceDisconnected, object: nil, queue: OperationQueue.main) { (notification) in
            DispatchQueue.main.async {
                let peripheral = notification.userInfo!["peripheral"] as! CBPeripheral
                if let index = self.cells[self.connected].firstIndex(where: {$0.name == peripheral.name && $0.id == peripheral.identifier.uuidString}) {
                    self.cells[self.connected].remove(at: index)
                }
                let alert = UIAlertController(title: "Disconnected from \(peripheral.name ?? "Unknown")", message: "Disconnected from device with id: \(peripheral.identifier).", preferredStyle: .alert)
                let action = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                    self.cells[self.disconnected] = [Device]()
                    self.tableView.reloadData()
                    self.bluetoothManager.refresh()
                })
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
        nc.addObserver(forName: BluetoothManager.btDisabled, object: nil, queue: OperationQueue.main) { (notification) in
            let alert = UIAlertController(title: "Bluetooth is not enabled", message: "Enable Bluetooth to start scanning", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        nc.addObserver(self, selector: #selector(self.scanStarted), name: BluetoothManager.scanStarted, object: nil)
        nc.addObserver(self, selector: #selector(self.scanEnded), name: BluetoothManager.scanEnded, object: nil)
        
    }
    
    @objc func scanStarted() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Scanning", message: "Scanning for nearby bluetooth devices.", preferredStyle: .alert)
            self.present(alert, animated: true)
        }
    }
    
    @objc func scanEnded() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.tableView.refreshControl?.endRefreshing()
            for peripheral in self.bluetoothManager.disconnectedPeripherals {
                if !self.cells[self.connected].contains(where: {$0.id == peripheral.identifier.uuidString}) {
                    self.cells[self.disconnected].append(Device(name: peripheral.name ?? "Unknown", id: peripheral.identifier.uuidString, state: self.peripheralState[peripheral.state.rawValue], peripheral: peripheral))
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func deviceConnected(peripheral: CBPeripheral){
        DispatchQueue.main.async {
            //Move device into connected section
            if let index = self.cells[self.disconnected].firstIndex(where: {$0.name == peripheral.name && $0.id == peripheral.identifier.uuidString}) {
                self.cells[self.connected].append(self.cells[self.disconnected][index])
                self.cells[self.disconnected].remove(at: index)
                self.tableView.reloadData()
            }
            let alert = UIAlertController(title: "Connected to \(peripheral.name ?? "Unkown")", message: "Connected to device with id: \(peripheral.identifier.uuidString).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func deviceDisconnected(peripheral: CBPeripheral){
        DispatchQueue.main.async {
            //Move device into connected section
            if let index = self.cells[self.disconnected].firstIndex(where: {$0.name == peripheral.name && $0.id == peripheral.identifier.uuidString}) {
                self.cells[self.connected].append(self.cells[self.disconnected][index])
                self.cells[self.disconnected].remove(at: index)
                self.tableView.reloadData()
            }
            let alert = UIAlertController(title: "Connected to \(peripheral.name ?? "Unkown")", message: "Connected to device with id: \(peripheral.identifier.uuidString).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func configureVars() {
        cells.append([Device]())
        cells.append([Device]())
    }
    
    func configureTableView() {
        // Register the custom header view.
        tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        navigationItem.title = "Devices"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(handleRefreshControl))
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.register(DeviceCell.self, forCellReuseIdentifier: "DeviceCell")
        tableView.pin(to: view)
    }
    
    func configureRefreshControl() {
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action:
            #selector(handleRefreshControl),
                                            for: .valueChanged)
    }
    
    @objc func handleRefreshControl(){
        let alert = UIAlertController(title: "Find new devices?", message: "Would you like to scan for new devices?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (UIAlertAction) in
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.cells[self.disconnected] = [Device]()
            self.tableView.reloadData()
            self.bluetoothManager.refresh()
        }))
        self.present(alert, animated: true)
    }
}

extension DevicesViewController : DeviceDetailDelegate {
    func updateCells(cell: DeviceCell) {
        return
    }
    
    func disconnect(peripheral: CBPeripheral, controller: DeviceDetailController) {
        controller.dismiss(animated: true, completion: nil)
        self.bluetoothManager.disconnect(peripheral: peripheral)
    }
}

extension DevicesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            "sectionHeader") as! Header
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        view.backgroundView = backgroundView
        view.title.text = sections[section]
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell") as! DeviceCell
        let device = cells[indexPath.section][indexPath.row]
        cell.set(device: device)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DeviceCell
        
        if cells[connected].contains(where: {$0.name == cell.name && $0.id == cell.id}) {
            // create a new detail view for the current peripheral and pass it the required data
            let vc = DeviceDetailController()
            vc.delegate = self
            vc.cell = cell
            let peripheral = bluetoothManager.connectedPeripherals.first(where: {$0.identifier == cell.peripheral?.identifier }) //grab updated peripheral (connecting to it has updated the characteristic values)
            cell.peripheral = peripheral
            vc.peripheral = peripheral
            let deviceDetailController = UINavigationController(rootViewController: vc)
            self.present(deviceDetailController, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Connect to \(cell.name)?", message: "Connect to device with id: \(cell.id)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                if let peripheral = self.bluetoothManager.disconnectedPeripherals.first(where: {$0.identifier.uuidString == cell.id}) {
                    self.bluetoothManager.connect(peripheral: peripheral)
                }
            }))
            self.present(alert, animated: true)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
}
