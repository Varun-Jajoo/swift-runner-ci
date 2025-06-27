//
//  PersonalizeMole.swift
//  MyPT
//
//  Created by techsaga corp on 30/01/25.
//

import UIKit


// MARK: ------------ PersonalizedBaseModel
struct PersonalizedBaseModel: Codable {
    let status: Bool?
    let data: [PersonalizedDataModel]?
    let name, msg: String?
}

// MARK: ---------- PersonalizedDataModel
struct PersonalizedDataModel: Codable {
    let id: Int?
    let name: String
    let description: String?
    let image: String?
    let status: Int?
    let deletedAt: String?
    let createdAt, updatedAt: String?
    let selectImage: String?
    // These are not part of Codable
    var cachedSelectedImg: UIImage? = nil
    var cachedUnselectedImg: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, image, status
        case deletedAt = "deleted_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case selectImage = "select_image"
        //        case unSelectedImg, selectedImg
    }
}



