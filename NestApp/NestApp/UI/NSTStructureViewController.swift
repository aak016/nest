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
            }
        }
    }
    private var currentStructures: CurrentStructures?
    
    private var cameras: [String : Camera?] = [:]
    
    private static let camerasSection = "Cameras"
    private let sections = [NSTStructureViewController.camerasSection]

    open func configure(with structure: Structure, currentStructures: CurrentStructures) {
        
        self.structure = structure
        self.currentStructures = currentStructures
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if structure != nil {
            titleLabel.text = structure?.name
            tableView.reloadData()
        }
    }
    
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let selectedRow = tableView.indexPathForSelectedRow!
        
        if (sender! as! UITableViewCell).reuseIdentifier == "cameraCellId", cameras.count > selectedRow.row {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        
        if cameras.count > 0 {
            sections += 1
        }
        
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cameras.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cameraCellId")!
        
        if let camera = getCamera(for: indexPath.row) {
            cell.textLabel?.text = String(format: "%@ (%@)", camera.whereName!, camera.isOnline! ? "online" : "offline")
            cell.accessoryType = .disclosureIndicator
            
        } else {
            cell.textLabel!.text = "Unknown Camera"
            cell.accessoryType = .none
            
            let cameraId = getCameraId(for: indexPath.row)!
            currentStructures?.getCamera(id: cameraId, completion: { [weak self, weak tableView] (camera) in
                if camera != nil {
                    self?.cameras[cameraId] = camera
                    tableView?.reloadRows(at: [indexPath], with: .automatic)
                }
            })
        }
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NSTStructureViewController.headerHeight
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
