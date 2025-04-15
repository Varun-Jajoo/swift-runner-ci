//
//  ReviewPackageWithoutTrainerModel.swift
//  MyPT
//
//  Created by techsaga corp on 14/04/25.
//

import Foundation

struct ReviewPackageWithoutTrainerBaseModel: Codable {
    var status: Bool?
    var data: ReviewDataModel?
    var msg: String?
    let errors: [String: [String]]?
}

struct ReviewDataModel: Codable {
    var packageDetail: ReviewPackageDetailModel?
    var price:String?
    var studio: ValityStudioDetailModel?
    
    enum CodingKeys: String, CodingKey {
        case packageDetail , price, studio
    }
}

 //MARK: -------------- PackageDetailModel
 struct ReviewPackageDetailModel: Codable {
     var package, startDate, endDate, totalDuration: String?
     
     enum CodingKeys: String, CodingKey {
         case package
         case startDate = "start_date"
         case endDate = "end_date"
         case totalDuration = "total_duration"
     }
 }


