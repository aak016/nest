//
//  Thermostat.swift
//  NestApp
//
//  Created by Alexey Kondakov on 26/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

class Thermostat {
    open private(set) var id: String?
    open private(set) var structureId: String?
    
    open private(set) var whereName: String?
    
    open private(set) var temperatureScale: String?
    open private(set) var ambientTemperatureC: Int?
    open private(set) var ambientTemperatureF: Int?
    open private(set) var targetTemperatureHighC: Int?
    open private(set) var targetTemperatureHighF: Int?
    open private(set) var targetTemperatureLowC: Int?
    open private(set) var targetTemperatureLowF: Int?

    open class func parse(json: [String : Any]) -> Thermostat? {
        let thermostat = Thermostat()
        
        thermostat.id = json["device_id"] as? String
        thermostat.structureId = json["structure_id"]  as? String
        
        thermostat.whereName = json["where_name"] as? String
        
        thermostat.temperatureScale = json["temperature_scale"] as? String
        thermostat.ambientTemperatureC = json["ambient_temperature_c"] as? Int
        thermostat.ambientTemperatureF = json["ambient_temperature_f"] as? Int
        thermostat.targetTemperatureHighC = json["target_temperature_high_c"] as? Int
        thermostat.targetTemperatureHighF = json["target_temperature_high_f"] as? Int
        thermostat.targetTemperatureLowC = json["target_temperature_low_c"] as? Int
        thermostat.targetTemperatureLowF = json["target_temperature_low_f"] as? Int
        
        return thermostat
    }
    
    open func ambientTemperature() -> Int? {
        guard temperatureScale != nil else {
            return nil
        }
        
        switch temperatureScale! {
        case "C":
            return ambientTemperatureC
            
        case "F":
            return ambientTemperatureF
            
        default:
            return nil
        }
    }
    
    open func targetTemperatureRange() -> String? {
        guard temperatureScale != nil else {
            return nil
        }

        var low: Int?
        var high: Int?
        
        switch temperatureScale! {
        case "C":
            low = targetTemperatureLowC
            high = targetTemperatureHighC
            
        case "F":
            low = targetTemperatureLowF
            high = targetTemperatureHighF

        default:
            return nil
        }

        return low != nil && high != nil ? String(format: "(%d%@ - %d%@)", low!, temperatureScale!, high!, temperatureScale!) : nil
    }
}
