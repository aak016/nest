//
//  NSTConnectionService.swift
//  NestApp
//
//  Created by Alexey Kondakov on 25/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import Alamofire

class NSTConnectionService {
    
    private static let requestEndpointUrlFormat = "https://developer-api.nest.com/structures/%@"

    private func request(_ items: String, token: String, completion: @escaping ([String: Any]?) -> Void) {
        
        let url = URL(string: String(format: NSTConnectionService.requestEndpointUrlFormat, items))!
        let authString = String(format: "Bearer %@", token)
        Alamofire.request(url, method: .get, headers: ["Content-Type" : "application/json", "authorization" : authString])
            .validate()
            .responseJSON { (_response) in
                
                guard let response = _response.response else {
                    completion(nil)
                    return
                }
                
                if response.statusCode == 401, let length = response.allHeaderFields["Content-Length"] as? Int, length > 0, let count = response.url?.absoluteString.count, count > 0 {
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
    
    
}
