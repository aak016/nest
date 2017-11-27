//
//  AppDelegate.swift
//  NestApp
//
//  Created by Alexey Kondakov on 24/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private lazy var authenticationService: NSTAuthenticationService = {
        let service = NSTAuthenticationService()
        service.delegate = self
        return service
    } ()
    private lazy var structuresProvider: NSTStructuresProvider = {
        let structures = NSTStructuresProvider()
        structures.authenticationService = self.authenticationService
        return structures
    } ()
    
    private var initialViewController: NSTMainTableViewController!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let navigationViewController = storyboard.instantiateViewController(withIdentifier: "initialViewController") as! UINavigationController
        initialViewController = navigationViewController.viewControllers.first! as! NSTMainTableViewController
        
        initialViewController.authenticationService = authenticationService
        initialViewController.structuresProvider = structuresProvider
        
        self.window?.rootViewController = navigationViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }

}

extension AppDelegate: NSTAuthenticationServiceDelegate {
    func authenticationServiceReady(_ service: NSTAuthenticationService) {
        initialViewController.authenticationSuccessful()
    }
    
    func authenticationServiceFailed(_ service: NSTAuthenticationService) {
        initialViewController.authenticationFailed()
    }
    
    
}
