//
//  NSTAuthenticationService.swift
//  NestApp
//
//  Created by Alexey Kondakov on 25/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import Alamofire

protocol NSTAuthenticationServiceDelegate {
    func authenticationServiceReady(_ service: NSTAuthenticationService)
    func authenticationServiceFailed(_ service: NSTAuthenticationService)
}

class NSTAuthenticationService {
    
    private static let authorizationUrlFormat = "https://api.home.nest.com/oauth2/access_token?code=%@&client_id=%@&client_secret=%@&grant_type=authorization_code"
    private static let tokenKey = "accessTokenKey"
    private static let defaultsTokenKey = "accessTokenKey"
    private static let defaultsTokenDate = "accessTokenDateKey"
    
    private static let storedTokenTimeout: TimeInterval = 15*3600
    
    private(set) var token: String?
    
    open var delegate: NSTAuthenticationServiceDelegate?
    
    init() {
        let storedToken = UserDefaults.standard.string(forKey: NSTAuthenticationService.defaultsTokenKey)
        let storenTokenDate = UserDefaults.standard.value(forKey: NSTAuthenticationService.defaultsTokenDate) as? Date
        
        guard storedToken != nil, storenTokenDate != nil else {
            return
        }
        
        if storenTokenDate!.timeIntervalSinceNow <= 0 {
            return
        }
        
        token = storedToken
    }

    open func authorized() -> Bool {
        return (token?.count ?? 0) > 0
    }
    
    private func request(pin code: String, completion: @escaping (String?) -> Void) {
        let clientId = Constants.productId
        let clientSecret = Constants.productSecret

        let group = DispatchGroup()
        group.enter()
        
        let authorizationUrl = String(format: NSTAuthenticationService.authorizationUrlFormat, code, clientId, clientSecret)
        Alamofire.request(URL(string: authorizationUrl)!, method: .post, headers: ["Content-Type" : "form-data"])
            .validate()
            .responseJSON { [weak self] (response) in
                let result = response.result.value! as! [String: Any]
                let accessToken = result["access_token"] ?? ""
                
                self?.token = accessToken as? String
                group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            UserDefaults.standard.set(self.token, forKey: NSTAuthenticationService.defaultsTokenKey)
            UserDefaults.standard.set(Date(timeIntervalSinceNow: NSTAuthenticationService.storedTokenTimeout), forKey: NSTAuthenticationService.defaultsTokenDate)
            completion(self.token)
        }
    }
    
    open func setPin(_ pin: String) {
        request(pin: pin) { (_) in
            DispatchQueue.main.async {
                self.delegate?.authenticationServiceReady(self)
            }
        }
    }
}
