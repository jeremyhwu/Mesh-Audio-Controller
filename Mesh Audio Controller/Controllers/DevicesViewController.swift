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
    var tableView = UITableView()
    var cbManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var cbState = CBManagerState.unknown
    var cbPeripherals = [CBPeripheral]()
    var RSSIs = [NSNumber]()
    var characteristicValue = [CBUUID: NSData]()
    var characteristics = [String : CBCharacteristic]()
    var services : [CBUUID]?
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
        configureTableView()
        configureBluetooth()
        configureRefreshControl()
        configureVars()
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
    
    func configureBluetooth() {
        cbManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
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
            self.cbPeripherals = []
            self.cells[self.disconnected] = [Device]()
            self.tableView.reloadData()
            self.scan()
        }))
        self.present(alert, animated: true)
    }
    
    
    func scan(){
        print("Scanning for devices")
        //        cbManager.scanForPeripherals(withServices: [BTConstants.ServiceUUID], options: nil)
        cbManager.scanForPeripherals(withServices: nil, options: nil)
        let alert = UIAlertController(title: "Scanning", message: "Scanning for nearby bluetooth devices.", preferredStyle: .alert)
        self.present(alert, animated: true)
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            self.stopscan()
        }
    }
    func stopscan(){
        self.dismiss(animated: true, completion: nil)
        timer.invalidate()
        cbManager.stopScan()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
        for (peripheral) in cbPeripherals{
            if !cells[connected].contains(where: {$0.id == peripheral.identifier.uuidString}) {
                cells[disconnected].append(Device(name: peripheral.name ?? "Unknown", id: peripheral.identifier.uuidString, state: peripheralState[peripheral.state.rawValue], peripheral: peripheral))
            }
        }
        self.tableView.reloadData()
    }
}

extension DevicesViewController : DeviceDetailDelegate {
    func updateCells(cell: DeviceCell) {
        return
    }
    
    func disconnect(peripheral: CBPeripheral, controller: DeviceDetailController) {
        controller.dismiss(animated: true, completion: nil)
        self.disconnectFromDevice(peripheral: peripheral)
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
            vc.peripheral = cell.peripheral
            vc.cells = self.cells
            let deviceDetailController = UINavigationController(rootViewController: vc)
            self.present(deviceDetailController, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Connect to \(cell.name)?", message: "Connect to device with id: \(cell.id)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                let peripheral = self.cells[indexPath.section][indexPath.row]
                if let index = self.cbPeripherals.firstIndex(
                    where: {$0.name == peripheral.name && $0.identifier.uuidString == peripheral.id}) {
                    self.cells[self.disconnected].remove(at: indexPath.row)
                    self.cells[self.connected].append(peripheral)
                    self.connectToDevice(peripheral: self.cbPeripherals[index])
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    func connectToDevice(peripheral: CBPeripheral) {
        cbManager?.connect(peripheral, options: nil)
    }
    
    func disconnectFromDevice(peripheral : CBPeripheral){
        cbManager?.cancelPeripheralConnection(peripheral)
        //remove from cbperipherals and scan again. Apparently not supposed to use same peripheral twice
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
}

extension DevicesViewController : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){  //bluetooth is on, scanning can start
            scan()
        }
        else {
            let alertVC = UIAlertController(title: "Bluetooth is not enabled", message: "Enable Bluetooth to start scanning", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !cbPeripherals.contains(where: {$0.identifier == peripheral.identifier}){
            if peripheral.name != nil {
                peripheral.delegate = self
                cbPeripherals.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to peripheral")
        
        // Move from disconnected to connected
        peripheral.discoverServices(nil)
        print(peripheral.services as Any)
        print(peripheral.state)
        if let index = cells[disconnected].firstIndex(where: {$0.name == peripheral.name && $0.id == peripheral.identifier.uuidString}) {
            cells[connected].append(cells[disconnected][index])
            cells[disconnected].remove(at: index)
        }
        self.tableView.reloadData()
        let alert = UIAlertController(title: "Connected to \(peripheral.name ?? "Unkown")", message: "Connected to device with id: \(peripheral.identifier).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect to peripheral")
        let alert = UIAlertController(title: "Unable to connect to \(peripheral.name ?? "Unknown") ", message: "Cannot connect to device with id: \(peripheral.identifier).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let index = cells[connected].firstIndex(where: {$0.name == peripheral.name && $0.id == peripheral.identifier.uuidString}) {
            cells[disconnected].append(cells[connected][index])
            cells[connected].remove(at: index)
        }
        self.tableView.reloadData()
        let alert = UIAlertController(title: "Disconnected from \(peripheral.name ?? "Unknown")", message: "Disconnected from device with id: \(peripheral.identifier).", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
            self.cbPeripherals = []
            self.cells[self.disconnected] = [Device]()
            self.tableView.reloadData()
            self.scan()
        })
        alert.addAction(action)
        self.present(alert, animated: true)
        print("disconnected from peripheral")
    }
}

extension DevicesViewController : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        return
    }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        return
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        return
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(peripheral.services as Any)
    }
}

extension DevicesViewController : CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if (peripheral.state == .poweredOn){
            
        }
    }
}
