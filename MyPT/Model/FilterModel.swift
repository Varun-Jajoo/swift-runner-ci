//
//  FilterModel.swift
//  MyPT
//
//  Created by techsaga corp on 03/07/25.
//

import Foundation

// MARK: ----------------- FilterTrainerBaseModel
struct FilterTrainerBaseModel: Codable {
    var status: Bool?
    var data: FilterTrainerDataModel?
    var msg: String?
}

// MARK: ---------- FilterTrainerDataModel
struct FilterTrainerDataModel: Codable {
    var nationalities: [FilterLstDataModel]?
    var languages: [FilterLstDataModel]?
    var gender: [FilterLstDataModel]?
    var time_slots: [FilterLstDataModel]?
}


// MARK: -------------- LanguageModel
struct FilterLstDataModel: Codable {
    var id: FlexibleValue?
    var name, iso6391, nationality: String?
    var isSelected: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, nationality
        case iso6391 = "iso_639-1"
        case isSelected
    }
}

/*
 // MARK: ---------- FilterTrainerDataModel
 //struct FilterTrainerDataModel: Codable {
 //    var nationalities: [NationalityModel]?
 //    var languages: [LanguageModel]?
 //    var gender: [GenderModel]?
 //}
 
// MARK: ------------ GenderModel
struct GenderModel: Codable {
    var id, name: String?
}

// MARK: -------------- LanguageModel
struct LanguageModel: Codable {
    var id: FlexibleValue?
    var name, iso6391: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case iso6391 = "iso_639-1"
    }
}

// MARK: ---------------- NationalityModel
struct NationalityModel: Codable {
    var id: FlexibleValue?
    var nationality: String?
}
*/

// MARK: - Welcome
struct HomepgaeBanner: Codable {
    let status: Bool?
    let data: [HomepageBannerData]?
    let msg: String?
}

// MARK: - Datum
struct HomepageBannerData: Codable {
    let id: Int?
    let image: String?
}
