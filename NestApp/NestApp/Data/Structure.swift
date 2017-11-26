//
//  Structure.swift
//  NestApp
//
//  Created by Alexey Kondakov on 26/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

class Structure {
    open var name: String?
    
    open class func parse(json: [String : Any]) -> Structure? {
        let structure = Structure()
        
        structure.name = json["name"] as? String
        
        return structure
    }
}
