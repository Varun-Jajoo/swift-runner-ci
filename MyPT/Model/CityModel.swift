//
//  CityModel.swift
//  MyPT
//
//  Created by techsaga corp on 20/03/25.
//

import Foundation

//MARK: -------------AddressBaseModel
//struct AddressBaseModel: Codable {
//    var status: Bool?
//    var data: AddressDataModel?
//    var msg: String?
//        
//    init(from decoder: Decoder) throws{
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        status = try container.decodeIfPresent(Bool.self, forKey: .status)
//        msg = try container.decodeIfPresent(String.self, forKey: .msg)
//        
//        // Handle `data` as both an array and a dictionary
//        if let dataDictionary = try? container.decode(AddressDataModel.self, forKey: .data) {
//            data = dataDictionary
//        } else if let dataArray = try? container.decode([AddressDataModel].self, forKey: .data), let firstElement = dataArray.first {
//            data = firstElement
//        } else {
//            data = nil
//        }
//    }
//}


struct AddressBaseModel: Codable {
    var status: Bool?
    var data: [AddressDataModel]?
    var msg: String?
    let errors: [String: [String]]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(Bool.self, forKey: .status)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        errors = try container.decodeIfPresent([String: [String]].self, forKey: .errors)
        
        // Try decoding as an array first
        if let dataArray = try? container.decode([AddressDataModel].self, forKey: .data) {
            data = dataArray
        }
        // If `data` is a single object, wrap it into an array
        else if let singleObject = try? container.decode(AddressDataModel.self, forKey: .data) {
            data = [singleObject]
        }
        // If `data` is null or invalid
        else {
            data = nil
        }
    }
}


// MARK: ------ AddressDataModel
struct AddressDataModel: Codable {
    var user_id: FlexibleValue?
    var building_name: FlexibleValue?
    var street: FlexibleValue?
    var city_id: FlexibleValue?
    var country_id: FlexibleValue?
    var city_name: String?
    var country_name: String?
    var landmark: String?
    var type: String?
    var mobile_no: FlexibleValue?
    var lat: FlexibleValue?
    var long: FlexibleValue?
    var updated_at: String?
    var created_at: String?
    var id: FlexibleValue?
    
    enum CodingKeys: String, CodingKey {
        case user_id, building_name, street, city_id, country_id, landmark, type, mobile_no
        case lat, long, updated_at, created_at, id, city_name, country_name
    }
}


//MARK: ------------ CityBaseModel
struct CityBaseModel: Codable {
    var status: Bool?
    var data: CityDataModel?
    var msg: String?
}

// MARK: - CityDataModel
struct CityDataModel: Codable {
    var id: Int?
    var name, phonecode: String?
    var iso2: String?
    var currency: String?
    var cities: [CityModel]?
}

// MARK: - CityModel
struct CityModel: Codable {
    var id: Int?
    var name: String?
    var stateID: Int?
    var stateCode: String?
    var countryID: Int?
    var countryCode: String?
    var latitude, longitude: String?
    var createdAt, updatedAt: String?
    var flag: Int?
    var wikiDataID: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case stateID = "state_id"
        case stateCode = "state_code"
        case countryID = "country_id"
        case countryCode = "country_code"
        case latitude, longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case flag
        case wikiDataID = "wikiDataId"
    }
}


