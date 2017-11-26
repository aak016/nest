//
//  CurrentStructures.swift
//  NestApp
//
//  Created by Alexey Kondakov on 26/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import Foundation

class CurrentStructures {
    
    private var cachedStructures: [Structure]?
    private var cachedCameras: [Camera] = []
    private var cachedThermostats: [Thermostat] = []
    
    var authenticationService: NSTAuthenticationService? {
        didSet {
            self.connectionService.authenticationService = authenticationService
        }
    }
    
    private var connectionService = NSTConnectionService()
    
    open func getStructures(completion: @escaping([Structure]?) -> Void) {
        
        if let structures = cachedStructures {
            DispatchQueue.main.async {
                completion(structures)
            }
        } else {
            connectionService.requestStructures { (result) in
                self.cachedStructures = result
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    open func getCamera(id: String, completion: @escaping(Camera?) -> Void) {
        if let camera = cachedCameras.first(where: { $0.id != nil && $0.id! == id }) {
            DispatchQueue.main.async {
                completion(camera)
            }
        } else {
            connectionService.requestCamera(id: id, completion: { [weak self] (camera) in
                DispatchQueue.main.async {
                    if camera != nil {
                        self?.cachedCameras = self?.cachedCameras.filter { return $0.id != id } ?? []
                        self?.cachedCameras.append(camera!)
                    }
                    completion(camera)
                }
            })
        }
    }
    
    open func getThermostat(id: String, completion: @escaping(Thermostat?) -> Void) {
        if let thermostat = cachedThermostats.first(where: { $0.id != nil && $0.id! == id }) {
            DispatchQueue.main.async {
                completion(thermostat)
            }
        } else {
            connectionService.requestThermostat(id: id, completion: { [weak self] (thermostat) in
                DispatchQueue.main.async {
                    if thermostat != nil {
                        self?.cachedThermostats = self?.cachedThermostats.filter { return $0.id != id } ?? []
                        self?.cachedThermostats.append(thermostat!)
                    }
                    completion(thermostat)
                }
            })
        }
    }
    
    open func invalidate() {
        cachedStructures = nil
        cachedCameras = []
    }
}
