//
//  DemoModel.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import Foundation


// MARK: ------ LoginBaseModel
struct LoginBaseModel: Codable {
    var status: Bool?
    var data: LoginDataModel?
    var msg: String?
    let errors: [String: [String]]?
}


// MARK: ------- LoginDataModel
struct LoginDataModel: Codable {
    var number, countyCode: String?

    enum CodingKeys: String, CodingKey {
        case number
        case countyCode = "county_code"
    }
}

// MARK: ------- submit otp
struct SubmitOtpBaseModel: Codable {
    var status: Bool?
    var data: SubmitDataModel?
    var msg: String?
    let errors: [String: [String]]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(Bool.self, forKey: .status)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        errors = try container.decodeIfPresent([String: [String]].self, forKey: .errors)

        // Handle `data` as both an array and a dictionary
        if let dataDictionary = try? container.decode(SubmitDataModel.self, forKey: .data) {
            data = dataDictionary
        } else if let dataArray = try? container.decode([SubmitDataModel].self, forKey: .data), let firstElement = dataArray.first {
            data = firstElement
        } else {
            data = nil
        }
    }
}

// MARK: - OtpDataModel
struct SubmitDataModel: Codable {
    var user: UserModel?
    var step: FlexibleValue?
    var token: FlexibleValue?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        step = try container.decodeIfPresent(FlexibleValue.self, forKey: .step)
        token = try container.decodeIfPresent(FlexibleValue.self, forKey: .token)

        // Handle `data` as both an array and a dictionary
        if let dataDictionary = try? container.decode(UserModel.self, forKey: .user) {
            user = dataDictionary
        } else if let dataArray = try? container.decode([UserModel].self, forKey: .user), let firstElement = dataArray.first {
            user = firstElement
        } else {
            user = nil
        }
    }
}

// MARK: - UserModel / otp + add anme 
struct UserModel: Codable {
    let id: Int?
    let name: String?
    let email: String?
    let phone: String?
    let isCompleted: Int?
    let dob, gender: String?
    let information: InformationModel?

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone
        case isCompleted = "is_completed"
        case dob, gender, information
    }
}


// MARK: ------- WeightBaseModel
struct WeightBaseModel: Codable {
    let status: Bool?
    let data: [UserModel]?
    let msg: String?
    let errors: [String: [String]]?
}


// MARK: --------- InformationModel
struct InformationModel: Codable {
    let id, userID: FlexibleValue?
    let weight, height: FlexibleValue?
    let userGoals, userPrefernce, long, lat, address: FlexibleValue?
    let createdAt, updatedAt: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case weight, height
        case userGoals = "user_goals"
        case userPrefernce = "user_prefernce"
        case long, lat, address
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}



// MARK: - FlexibleValue
/* used top get value
 print(model.height?.value)     // "170"
 print(model.height?.intValue)  // 170
 print(model.weight?.intValue)
 print(model.height?.value)     // "170.2"
 print(model.height?.doubleValue)  // 170.2
 print(model.isActive?.value)     // "true"
 print(model.isActive?.boolValue) // true
 */
struct FlexibleValue: Codable {
    let value: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Try decoding as different types and store as String
        if let intValue = try? container.decode(Int.self) {
            value = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            value = String(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            value = String(boolValue)
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else {
            value = nil
        }
    }
    
    // Explicitly encode only the value
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    // Provide convenience getters
    var intValue: Int? { return Int(value ?? "") }
    var doubleValue: Double? { return Double(value ?? "") }
    var boolValue: Bool? { return Bool(value ?? "") }
}

