//
//  SettingsViewController.swift
//  Mesh Audio Controller
//
//  Created by jeremy Wu on 10/30/19.
//  Copyright © 2019 jeremy Wu. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : UITableViewController {
    var deviceTab : DevicesViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
