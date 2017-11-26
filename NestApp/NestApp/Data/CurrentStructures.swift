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
        
    }
    
    open func invalidate() {
        cachedStructures = nil
    }
}
