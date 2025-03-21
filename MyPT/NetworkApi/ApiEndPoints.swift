//
//  ApiEndPoints.swift
//  MyPT
//
//  Created by techsaga corp on 27/01/25.
//

import Foundation
import Alamofire

var APISuccessCode:Int        { return 200 }
var InvalidAccessTokenCode:Int { return 401 }
var Registered:Int            { return 201 }
var badRequest: Int      { return 400 }
var pageNotFound: Int      { return 404 }
var success: Int      { return 2000 }
var failure: Int       {return 2999}
var recordFound: Int      { return 2001 }
var noRecordFound: Int      { return 2002 }
var recordAlreadyExist: Int      { return 2003}

///App base urls
enum AppBaseUrl:String {
    case baseScheme = "http"
    case baseDevUrl = "mypt.techsaga.live"
    case baseProductionUrl = ""
}

///base url : - http://mypt.techsaga.live/
///App api end points
enum ApiEndPoint: String{
    case readMessage
    case login                =  "api/login"
    case resend_Otp           =  "api/resendotp"
    case submit_Otp           =  "api/submit-otp"
    case check_Step           =  "api/step"
    case add_name             =  "api/add-name"
    case get_prefrences       =  "api/get-prefrences"
    case add_prefrence        =  "api/add/prefrence"
    case add_gender           =  "api/add/gender"
    case add_dob              =  "api/add/dob"
    case add_height           =  "api/add/height"
    case add_weight           =  "api/add/weight"
    case get_goals            =  "api/get-goals"
    case add_goal             =  "api/add/goal"
    case add_preferwork       =  "api/preferwork"
    case add_location         =  "api/add/location"
    case workouts             =  "api/workouts"
    case get_trainer          =  "api/get-trainer"
    case trainer_details      =  "api/trainer-details"
    case select_gym           =  "api/select/gym"
    case studio_details       =  "api/studio-details"
    case get_availability     =  "api/get-availability"
    case add_address          =  "api/add-address"
    case get_cities           =  "api/get-cities"
    case get_address          =  "api/get-address"
   
  
    case authLoginOTP = "authLoginOTP"
    case refreshAccessToken = "refreshToken"
    
    func getURL(queries: [String: String]?) -> URL?{
        let url = URLBuilder()
            .set(path: self.rawValue)
            .addQueryItem(queries: queries)
            .build()
        return url
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .readMessage:
            return ["accept": "text/plain","x-api-version":"1.0","Content-Type":"application/json"]
        default:
            return ["accept": "*/*"]
        }
    }
}
