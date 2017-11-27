//
//  NSTThermostatViewController.swift
//  NestApp
//
//  Created by Alexey Kondakov on 27/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import UIKit

class NSTThermostatViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var thermostat: Thermostat?
    
    func configure(thermostat: Thermostat) {
        self.thermostat = thermostat
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = thermostat?.whereName
        tableView.reloadData()
    }
}

extension NSTThermostatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thermostatCellId")!
        
        switch indexPath.row {
            
        case 0:
            cell.textLabel?.text = "Location"
            cell.detailTextLabel?.text = thermostat?.whereName
            
        case 1:
            cell.textLabel?.text = "Temperature"
            
            let temperatureString = thermostat?.ambientTemperature() != nil && thermostat?.temperatureScale != nil ? String(format: "%d %@", thermostat!.ambientTemperature()!, thermostat!.temperatureScale!) : ""
            cell.detailTextLabel?.text = temperatureString
            
        case 2:
            cell.textLabel?.text = "Temp Range"
            cell.detailTextLabel?.text = thermostat?.targetTemperatureRange() ?? ""
            
        default:
            return UITableViewCell()
        }
        
        return cell
    }
}
