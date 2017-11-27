//
//  NSTMainTableViewController.swift
//  NestApp
//
//  Created by Alexey Kondakov on 25/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import UIKit

class NSTMainTableViewController: UIViewController {
    
    open var authenticationService: AuthenticationProtocol!
    open var structuresProvider: StructuresProviderProtocol!
    
    private var structures: [Structure]?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "My Structures"
        
        let reloadItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(reload(_:)))
        navigationItem.rightBarButtonItem = reloadItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if authenticationService.needsPin {
            populateTable()
        } else {
            presentAuthenticationController()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let selectedIndexPath = tableView.indexPathForSelectedRow!
        
        if identifier == "pushStructureSegue", structures != nil, structures!.count > selectedIndexPath.row {
            return true
        } else {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let selectedIndexPath = tableView.indexPathForSelectedRow
        if  selectedIndexPath != nil {
            tableView.deselectRow(at: selectedIndexPath!, animated: true)
        }
        
        if segue.identifier == "pushStructureSegue" {
            let destination = segue.destination as! NSTStructureViewController
            
            if selectedIndexPath != nil, structures != nil {
                let structure = structures![selectedIndexPath!.row]
                destination.configure(with: structure, structuresProvider: structuresProvider)
            } else {
                assert(false, "shouldPerformSegue had to prevent this situation!")
            }
        }
    }
    
    private func presentAuthenticationController() {
        if !authenticationService.needsPin {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let authController = storyboard.instantiateViewController(withIdentifier: "authenticationVC") as! NSTAuthenticationViewController
            authController.configure(clientId: Constants.productId, state: "STATE")
            authController.delegate = self
            
            let navController = UINavigationController(rootViewController: authController)
            self.present(navController, animated: true, completion: nil)
        }
    }

    private func populateTable() {
        view.bringSubview(toFront: loadingIndicatorView)
        
        structuresProvider.getStructures { [weak self] (structures) in
            self?.structures = structures
            self?.tableView?.reloadData()
            
            if self != nil {
                self!.view.bringSubview(toFront: self!.tableView)
            }
        }
    }
    
   
    @objc private func reload(_: AnyObject) {
        structuresProvider.invalidate()
        populateTable()
    }
}

extension NSTMainTableViewController: UITableViewDataSource {
    
    private func structureDetail(for structure: Structure) -> String {
        let thermostatsLine = structure.thermostatsIds != nil && structure.thermostatsIds!.count > 0 ? String(format: "%d thermostat(s)", structure.thermostatsIds!.count) : nil
        let camerasLine = structure.camerasIds != nil && structure.camerasIds!.count > 0 ? String(format: "%d camera(s)", structure.camerasIds!.count) : nil
        
        var resultLine = thermostatsLine ?? ""
        
        if resultLine.count > 0 && camerasLine != nil {
            resultLine += ", "
        }
        
        if camerasLine != nil {
            resultLine += camerasLine!
        }
        
        return resultLine
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structures?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "structureCellId")!
        
        cell.textLabel?.text = structures![indexPath.row].name
        cell.detailTextLabel?.text = structureDetail(for: structures![indexPath.row])
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension NSTMainTableViewController: NSTAuthenticationViewControllerDelegate {
    func viewController(_: NSTAuthenticationViewController, receivedPin pin: String) {
        dismiss(animated: true, completion: nil)
        authenticationService.setPin(pin)
    }
}

extension NSTMainTableViewController {
    func authenticationSuccessful() {
        populateTable()
    }
    
    func authenticationFailed() {
        let alert = UIAlertController(title: "Error", message: "The entered PIN was not accepted.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
