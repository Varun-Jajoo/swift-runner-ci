//
//  ExploreWorkoutModel.swift
//  MyPT
//
//  Created by techsaga corp on 11/02/25.
//

import Foundation

// MARK: - Base Model
struct DashboardBaseModel: Codable {
    var status: Bool?
    var data: DataModel?
    var msg: String?
}

// MARK: --------- DataModel
struct DataModel: Codable {
    var categories: [CategoryModel]?
    var featured: [FeaturedModel]?
    var myworkouts, challanges: FlexibleValue
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        myworkouts = try container.decodeIfPresent(FlexibleValue.self, forKey: .myworkouts)
//        challanges = try container.decodeIfPresent(FlexibleValue.self, forKey: .challanges)
//
//        // Handle `data` as both an array and a dictionary
//        if let dataDictionary = try? container.decode(CategoryModel.self, forKey: .categories) {
//            categories = dataDictionary
//        }else if let dataArray = try container.decodeIfPresent([CategoryModel].self, forKey: .categories), let firstElement = dataArray.first {
//            categories = firstElement
//        }else{
//            categories = nil
//        }
//        if let dataDictionary = try? container.decode(FeaturedModel.self, forKey: .featured) {
//            featured = dataDictionary
//        }else if let dataArray = try container.decodeIfPresent([FeaturedModel].self, forKey: .categories), let firstElement = dataArray.first {
//            featured = firstElement
//        }else{
//            featured = nil
//        }
//    }
}

// MARK: -------- CategoryModel
struct CategoryModel: Codable {
    var name: FlexibleValue
    var image: FlexibleValue
    var id: FlexibleValue
}

// MARK: --------- FeaturedModel
struct FeaturedModel: Codable {
    var id: FlexibleValue
    var title: FlexibleValue
    var image: FlexibleValue
    var status: FlexibleValue
    var description, createdAt, updatedAt: FlexibleValue
    var calories: FlexibleValue
    var seriesName: FlexibleValue

    enum CodingKeys: String, CodingKey {
        case id, title, image, status, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case calories
        case seriesName = "series_name"
    }
}


