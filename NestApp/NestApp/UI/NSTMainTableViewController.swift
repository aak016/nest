//
//  NSTMainTableViewController.swift
//  NestApp
//
//  Created by Alexey Kondakov on 25/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import UIKit

class NSTMainTableViewController: UIViewController {
    
    private var needToRequestPIN = false
    private lazy var authenticationService: NSTAuthenticationService = {
        let service = NSTAuthenticationService()
        service.delegate = self
        return service
    } ()
    private lazy var currentStructures: CurrentStructures = {
        let structures = CurrentStructures()
        structures.authenticationService = self.authenticationService
        return structures
    } ()
    
    
    private var structures: [Structure]?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        needToRequestPIN = true
        
        let reloadItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(reload(_:)))
        navigationItem.rightBarButtonItem = reloadItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentAuthenticationController()
    }
    
    private func presentAuthenticationController() {
        if needToRequestPIN && !authenticationService.authorized() {
            needToRequestPIN = false
            
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
        
        currentStructures.getStructures { [weak self] (structures) in
            self?.structures = structures
            self?.tableView?.reloadData()
            
            if self != nil {
                self!.view.bringSubview(toFront: self!.tableView)
            }
        }
    }
    
    private func reportTokenFailure() {
        let alert = UIAlertController(title: "Error", message: "Could not receive a security token from Nest server.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .destructive, handler: nil))
        
        self.present(alert, animated: true) { [weak self] in
            self?.needToRequestPIN = true
            self?.presentAuthenticationController()
        }
    }
    
    @objc private func reload(_: AnyObject) {
        currentStructures.invalidate()
        populateTable()
    }
}

extension NSTMainTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structures?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "structureCellId")!
        
        cell.textLabel?.text = structures![indexPath.row].name
        
        return cell
    }
}

extension NSTMainTableViewController: NSTAuthenticationViewControllerDelegate {
    func viewController(_: NSTAuthenticationViewController, receivedPin pin: String) {
        dismiss(animated: true, completion: nil)
        authenticationService.setPin(pin)
    }
}

extension NSTMainTableViewController: NSTAuthenticationServiceDelegate {
    func authenticationServiceReady(_ service: NSTAuthenticationService) {
        populateTable()
    }
    
    func authenticationServiceFailed(_ service: NSTAuthenticationService) {
        needToRequestPIN = true
        presentAuthenticationController()
    }
}
