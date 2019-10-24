//
//  DevicesViewController.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 10/23/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesViewController: UIViewController {
    
    var tableView = UITableView()
    var cbManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var cbState = CBManagerState.unknown
    var cbPeripherals = [CBPeripheral]()
    var RSSIs = [NSNumber]()
    var characteristicValue = [CBUUID: NSData]()
    var characteristics = [String : CBCharacteristic]()
    var dataSource : UITableViewDataSource?
    var timer = Timer()
    var cells: [Device] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureBluetooth()
    }
    
    func configureTableView() {
        navigationItem.title = "Devices"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        //register cells
        tableView.pin(to: view)
    }
    
    func configureBluetooth() {
        cbManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func scan(){
        print("Scanning for devices")
        //        cbManager.scanForPeripherals(withServices: [BTConstants.ServiceUUID], options: nil)
        cbManager.scanForPeripherals(withServices: nil, options: nil) //for debugging, find all bt devices
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            self.stopscan()
        }
    }
    func stopscan(){
        timer.invalidate()
        cbManager.stopScan()
        for (peripheral) in cbPeripherals{
            print(peripheral)
        }
    }
    
     @objc func handleRefreshControl(){
            // Reset vars and scan again
            self.cbPeripherals = []
            tableView.reloadData()
            self.scan()
            // Dismiss the refresh control.
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
}

extension DevicesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
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
            cbPeripherals.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to peripheral")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect to peripheral")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected from peripheral")
    }
}

extension DevicesViewController : CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if (peripheral.state == .poweredOn){
            
        }
    }
}
