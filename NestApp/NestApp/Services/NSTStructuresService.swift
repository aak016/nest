//
//  NSTStructuresService.swift
//  NestApp
//
//  Created by Alexey Kondakov on 25/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import Alamofire

class NSTStructuresService {
    
    open var authenticationService: NSTAuthenticationService?
    
    private static let requestEndpointUrlFormat = "https://developer-api.nest.com/%@"

    private func request(_ items: String, token: String, completion: @escaping ([String: Any]?) -> Void) {
        
        let url = URL(string: String(format: NSTStructuresService.requestEndpointUrlFormat, items))!
        let authString = String(format: "Bearer %@", token)
        Alamofire.request(url, method: .get, headers: ["Content-Type" : "application/json", "authorization" : authString])
            .validate()
            .responseJSON { (_response) in
                
                guard let response = _response.response else {
                    completion(nil)
                    return
                }
                
                if response.statusCode == 401, let count = response.url?.absoluteString.count, count > 0 {
                    // a redirect
                    self.redirect(to: response.url!.absoluteString, token: token, completion: completion)
                    
                } else if let result = _response.result.value as? [String: Any] {
                    completion(result)
                } else {
                    completion(nil)
                }
        }
    }
    
    private func redirect(to: String, token: String, completion: @escaping ([String : Any]?) -> Void) {
        
        let authString = String(format: "Bearer %@", token)
        
        Alamofire.request(to, method: .get, headers: ["Content-Type" :"application/json", "authorization" : authString])
            .responseJSON { (_response) in
                if let response = _response.result.value as? [String : Any] {
                    completion(response)
                } else {
                    completion(nil)
                    return
                }
        }
    }
    
    open func requestStructures(completion: @escaping ([Structure]?) -> Void) {
        
        assert(authenticationService != nil && authenticationService!.token != nil)
        let token = authenticationService!.token!
        
        var structures: [Structure] = []
        
        request("structures", token: token, completion: { (result) in
            guard result != nil else {
                return
            }
            
            let keys = Array(result!.keys)
            keys.forEach({ (key) in
                let structureJSON = result![key]! as! [String : Any]
                if let structure = Structure.parse(json: structureJSON) {
                    structures.append(structure)
                }
            })
            
            completion(structures)
        })
    }
    
    open func requestCamera(id: String, completion: @escaping (Camera?) -> Void) {
        assert(authenticationService != nil && authenticationService!.token != nil)
        let token = authenticationService!.token!
        
        request(String(format: "devices/cameras/%@", id), token: token, completion: { (result) in
            guard result != nil else {
                return
            }
            
            let camera = Camera.parse(json: result!)
            completion(camera)
        })
    }
    
    open func requestThermostat(id: String, completion: @escaping (Thermostat?) -> Void) {
        assert(authenticationService != nil && authenticationService!.token != nil)
        let token = authenticationService!.token!
        
        request(String(format: "devices/thermostats/%@", id), token: token, completion: { (result) in
            guard result != nil else {
                return
            }
            
            let camera = Thermostat.parse(json: result!)
            completion(camera)
        })
    }
}
