//
//  Camera.swift
//  NestApp
//
//  Created by Alexey Kondakov on 26/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

class Camera {
    open private(set) var id: String?
    open private(set) var structureId: String?
    
    open private(set) var whereName: String?
    open private(set) var isOnline: Bool?
    open private(set) var snapshotUrl: String?
    open private(set) var lastOnlineDate: String?
    
    open class func parse(json: [String : Any]) -> Camera {
        let camera = Camera()
        
        camera.id = json["device_id"] as? String
        camera.structureId = json["structure_id"] as? String
        
        camera.whereName = json["where_name"] as? String
        camera.isOnline = json["is_online"] as? Bool 
        camera.snapshotUrl = json["snapshot_url"] as? String
        camera.lastOnlineDate = json["last_is_online_change"] as? String
        
        return camera
    }
}
