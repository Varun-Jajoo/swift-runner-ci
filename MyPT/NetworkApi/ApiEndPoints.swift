//
//  ApiEndPoints.swift
//  MyPT
//
//  Created by techsaga corp on 27/01/25.
//

import Foundation
import Alamofire

var APISuccessCode:Int            { return 200 }
var InvalidAccessTokenCode:Int    { return 401 }
var Registered:Int                { return 201 }
var badRequest: Int               { return 400 }
var pageNotFound: Int             { return 404 }
var success: Int                  { return 2000 }
var failure: Int                  { return 2999 }
var recordFound: Int              { return 2001 }
var noRecordFound: Int            { return 2002 }
var recordAlreadyExist: Int       { return 2003}

var isTesting:Bool                { return false }


//App base urls
enum AppBaseUrl:String {
    case baseScheme = "https" //"http"
    case baseDevUrl = "mobileapp.mypt-me.com"  //"mypt.techsaga.live"
    case baseProductionUrl = ""
}

//base url : - https://mobileapp.mypt-me.com -> for live
//base url : - http://mypt.techsaga.live/

//App api end points
enum ApiEndPoint: String{
    case readMessage
    case login                          =  "api/login"
    case resend_Otp                     =  "api/resendotp"
    case submit_Otp                     =  "api/submit-otp"
    case check_Step                     =  "api/step"
    case add_name                       =  "api/add-name"
    case get_prefrences                 =  "api/get-prefrences"
    case add_prefrence                  =  "api/add/prefrence"
    case add_gender                     =  "api/add/gender"
    case add_dob                        =  "api/add/dob"
    case add_height                     =  "api/add/height"
    case add_weight                     =  "api/add/weight"
    case get_goals                      =  "api/get-goals"
    case add_goal                       =  "api/add/goal"
    case add_preferwork                 =  "api/preferwork"
    case add_location                   =  "api/add/location"
    case workouts                       =  "api/workouts"
    case get_trainer                    =  "api/get-trainer"
    case trainer_details                =  "api/trainer-details"
    case select_gym                     =  "api/select/gym"
    case studio_details                 =  "api/studio-details"
    case get_availability               =  "api/get-availability"
    case add_address                    =  "api/add-address"
    case get_cities                     =  "api/get-cities"
    case get_address                    =  "api/get-address"
    case get_slots                      =  "/api/get-slots"
    case book_slot                      =  "api/book-slot"
    case package_create_one_buddy       =  "api/package-create"
    case package_setdate                =  "api/package-setdate"
    case package_checkout               =  "api/package-checkout"
    case get_maember_package_group      =  "api/package-group"
    case add_member                     =  "api/add-member"
    case delete_member                  =  "api/delete-member"
    case trainer_follow                 =  "api/trainer-follow"
    case membership_validity            =  "api/membership-validity"
    case review_package_membership      =  "api/review-package"
    case book_membership                =  "api/book-membership"
    case get_booking                    =  "api/get-booking"
    case booking_detail                 =  "api/booking-detail"
    case accept_reject_Booking          =  "api/accept-reject"
    case get_trainerSlot                =  "api/get-trainerslot"
    case get_allslots_Reschedule        =  "api/get-allslots"
    case reschedule_session_Consumer    =  "api/reschedule-session"
    case cancel_request                 =  "api/cancel-request"
    case cancel_session                 =  "api/cancel-session"
    case check_type_Package             =  "api/check-type"
    case upcoming_classes               =  "api/upcoming-classes"
    case get_resources                  =  "api/get-resources"
    case class_detail                   =  "api/class-detail"
    case viewall_classes                =  "api/viewall-classes"
    case class_category                 =  "api/class-category"
    case book_class                     =  "api/book-class"
    case ccaavenue_payment              =  "api/pay"
    case account_delete                 =  "api/account-delete"
    
  
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
