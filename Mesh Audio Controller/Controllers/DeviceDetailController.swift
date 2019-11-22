//
//  DeviceDetailController.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 11/14/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceDetailController: UITableViewController {
    var delegate : DeviceDetailDelegate?
    var cell : DeviceCell?
    var peripheral : CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTable()
    }
    
    func configureUI(){
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
//    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Disconnect", style: .done, target: self, action: #selector(handleDisconnect))
    view.backgroundColor = .white
    }
    
    func configureTable(){
        
    }
    
    @objc func handleDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDisconnect() {
        let alert = UIAlertController(title: "Disconnect?", message: "Disconnect from this device?", preferredStyle: .alert)
//                   alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
//                   alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
//                       let peripheral = self.cells[indexPath.section][indexPath.row]
//                       if let index = self.cbPeripherals.firstIndex(
//                           where: {$0.name == peripheral.name && $0.identifier.uuidString == peripheral.id}) {
//                           self.cells[self.connected].remove(at: indexPath.row)
//                           self.cells[self.disconnected].append(peripheral)
//                           self.disconnectFromDevice(peripheral: self.cbPeripherals[index])
//                       }
        self.dismiss(animated: true, completion: nil)
    }
}

