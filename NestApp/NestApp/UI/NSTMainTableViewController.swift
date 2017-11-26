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
    private var authenticationService = NSTAuthenticationService()
    private var devicesService = NSTConnectionService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        needToRequestPIN = true
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

    private func populateTableView() {
        if let token = authenticationService.token {
            devicesService.request("structures", token: token, completion: { (response) in
                
            })
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
}

extension NSTMainTableViewController: NSTAuthenticationViewControllerDelegate {
    func viewController(_: NSTAuthenticationViewController, receivedCredentials credentials: String) {
        self.dismiss(animated: true, completion: nil)
        
        authenticationService.request(authorizationCode: credentials) { (_token) in
            if let token = _token {
                self.populateTableView()
            } else {
                self.reportTokenFailure()
            }
        }
    }
}
