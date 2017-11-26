//
//  Structure.swift
//  NestApp
//
//  Created by Alexey Kondakov on 26/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

class Structure {
    open private(set) var name: String!
    open private(set) var id: String!
    open private(set) var camerasIds: [String]?
    open private(set) var thermostatsIds: [String]?
    
    open class func parse(json: [String : Any]) -> Structure? {
        let structure = Structure()
        
        structure.name = json["name"] as! String
        structure.id = json["structure_id"]  as! String
        
        structure.camerasIds = json["cameras"] as? [String]
        structure.thermostatsIds = json["thermostats"] as? [String]
        
        return structure
    }
}
