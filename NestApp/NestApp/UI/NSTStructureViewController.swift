//
//  NSTStructureViewController.swift
//  NestApp
//
//  Created by Alexey Kondakov on 26/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import UIKit

class NSTStructureViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    private var structure: Structure? {
        didSet {
            if structure != nil {
                titleLabel?.text = structure!.name
                
                structure!.camerasIds?.forEach({ (cameraId) in
                    self.cameras[cameraId] = nil as Camera?
                })
                
                structure!.thermostatsIds?.forEach({ (thermostatId) in
                    self.thermostats[thermostatId] = nil as Thermostat?
                })
            }
        }
    }
    private var structuresProvider: StructuresProviderProtocol?
    
    private var cameras: [String : Camera?] = [:]
    private var thermostats: [String : Thermostat?] = [:]
    
    private static let camerasSection = "Cameras"
    private static let thermostatsSection = "Thermostats"
    private let sections = [NSTStructureViewController.camerasSection, NSTStructureViewController.thermostatsSection]

    open func configure(with structure: Structure, structuresProvider: StructuresProviderProtocol) {
        
        self.structure = structure
        self.structuresProvider = structuresProvider
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if structure != nil {
            navigationItem.title = structure!.name
            
            titleLabel.text = structure?.name
            tableView.reloadData()
        }
    }
    
    // MARK: - Home devices handling
    
    private func getCameraId(for index: Int) -> String? {
        guard cameras.count > index else {
            return nil
        }
        
        return Array(cameras.keys)[index]
    }
    
    private func getCamera(for index: Int) -> Camera? {
        let cameraId = getCameraId(for: index)
        return cameraId != nil ? cameras[cameraId!]! : nil
    }
    
    private func getThermostatId(for index: Int) -> String? {
        guard thermostats.count > index else {
            return nil
        }
        
        return Array(thermostats.keys)[index]
    }
    
    private func getThermostat(for index: Int) -> Thermostat? {
        let thermostatId = getThermostatId(for: index)
        return thermostatId != nil ? thermostats[thermostatId!]! : nil
    }
    
    //MARK: - Segue support
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let selectedRow = tableView.indexPathForSelectedRow!
        
        if (sender! as! UITableViewCell).reuseIdentifier == "cameraCellId", getCamera(for: selectedRow.row) != nil {
            return true
        } else {
            tableView.deselectRow(at: selectedRow, animated: true)
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedRow = tableView.indexPathForSelectedRow!
        tableView.deselectRow(at: selectedRow, animated: true)
        
        if sections[selectedRow.section] == NSTStructureViewController.camerasSection {
            let foundCamera = getCamera(for: selectedRow.row)!
            (segue.destination as! NSTCameraViewController).configure(with: foundCamera)
        }
    }
}

extension NSTStructureViewController: UITableViewDataSource, UITableViewDelegate {
    
    private static let headerHeight: CGFloat = 40
    private static let labelHeight: CGFloat = 18
    
    private static let cameraSection = 0
    private static let thermostatSection = 1
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case NSTStructureViewController.cameraSection:
            return cameras.count
            
        case NSTStructureViewController.thermostatSection:
            return thermostats.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cameraCellForRowAt index: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cameraCellId")!
        
        if let camera = getCamera(for: index) {
            cell.textLabel?.text = String(format: "%@ (%@)", camera.whereName!, camera.isOnline! ? "online" : "offline")
            cell.accessoryType = .disclosureIndicator
            
        } else {
            cell.textLabel!.text = "Unknown Camera"
            cell.accessoryType = .none
            
            let cameraId = getCameraId(for: index)!
            structuresProvider?.getCamera(id: cameraId, completion: { [weak self, weak tableView] (camera) in
                if camera != nil {
                    self?.cameras[cameraId] = camera
                    tableView?.reloadRows(at: [IndexPath(row: index, section: NSTStructureViewController.cameraSection)], with: .automatic)
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, thermostatCellForRowAt index: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thermostatCellId")!
        
        if let thermostat = getThermostat(for: index) {
            let temperatureString = thermostat.ambientTemperature() != nil && thermostat.temperatureScale != nil ? String(format: "(%d%@)", thermostat.ambientTemperature()!, thermostat.temperatureScale!) : ""
            cell.textLabel?.text = String(format: "%@ %@", thermostat.whereName!, temperatureString)
            cell.accessoryType = .disclosureIndicator
            
        } else {
            cell.textLabel!.text = "Unknown Thermostat"
            cell.accessoryType = .none
            
            let thermostatId = getThermostatId(for: index)!
            structuresProvider?.getThermostat(id: thermostatId, completion: { [weak self, weak tableView] (thermostat) in
                if thermostat != nil {
                    self?.thermostats[thermostatId] = thermostat
                    tableView?.reloadRows(at: [IndexPath(row: index, section: NSTStructureViewController.thermostatSection)], with: .automatic)
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case NSTStructureViewController.cameraSection:
            return self.tableView(tableView, cameraCellForRowAt: indexPath.row)
            
        case NSTStructureViewController.thermostatSection:
            return self.tableView(tableView, thermostatCellForRowAt: indexPath.row)
            
        default:
            return UITableViewCell()
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let tinyNumber: CGFloat = 1e-18
        if section == NSTStructureViewController.cameraSection && cameras.count == 0 {
            return tinyNumber
        }
        if section == NSTStructureViewController.thermostatSection && thermostats.count == 0 {
            return tinyNumber
        }
        return NSTStructureViewController.headerHeight
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1e-18
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: NSTStructureViewController.headerHeight))
        
        let labelY = (NSTStructureViewController.headerHeight - NSTStructureViewController.labelHeight)/2
        let label = UILabel(frame: CGRect(x: 10, y: labelY, width: tableView.frame.size.width - 20, height: NSTStructureViewController.labelHeight))
        
        view.addSubview(label)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: NSTStructureViewController.labelHeight)
        label.text = sections[section]
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        return view
    }
}
