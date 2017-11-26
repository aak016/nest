//
//  NSTAuthenticationViewController.swift
//  NestApp
//
//  Created by Alexey Kondakov on 25/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import UIKit
import WebKit

protocol NSTAuthenticationViewControllerDelegate {
    func viewController(_: NSTAuthenticationViewController, receivedPin pin: String)
}

class NSTAuthenticationViewController: UIViewController {
    
    @IBOutlet private var webView: WKWebView!
    
    private var clientId: String!
    private var state: String!
    
    open var delegate: NSTAuthenticationViewControllerDelegate?

    open func configure(clientId: String, state: String = "STATE") {
        self.clientId = clientId
        self.state = state
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alertController = UIAlertController(title: nil, message: "Please log in inside the form below, memorize the provided PIN and press 'Dial PIN' button to enter it.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_: UIAlertAction) in
            if let strongSelf = self {
                let item = UIBarButtonItem(title: "Dial PIN", style: .plain, target: self, action: #selector(strongSelf.dialPin(_:)))
                strongSelf.navigationItem.rightBarButtonItem = item
            }
        }))
        
        if let url = URL(string: String(format: Constants.authorizationUrl, clientId, state)) {
            let request = URLRequest(url: url)
            webView.load(request)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc private func dialPin(_ sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: "Please dial the received PIN", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (_: UIAlertAction) in
            self.delegate?.viewController(self, receivedPin: (alert.textFields?.first?.text)!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension NSTAuthenticationViewController: WKNavigationDelegate {
    
}
