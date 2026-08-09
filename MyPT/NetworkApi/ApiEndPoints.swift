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
var recordAlreadyExist: Int       { return 2003 }

var isTesting: Bool               { return false }


//App base urls
enum AppBaseUrl: String {
    case baseScheme = "https"
    case baseDevUrl = "mobileappuat.mypt-me.com" // Staging URL
    case baseProductionUrl = "mobileapp.mypt-me.com" // Live URL
}


//base url : - https://mobileapp.mypt-me.com -> for live
//Testin base url : - https://mobileappuat.mypt-me.com/
//base url : - http://mypt.techsaga.live/


//App api end points
enum ApiEndPoint: String {
    case readMessage
    case login                          =  "api/login"
    case resend_Otp                     =  "api/resendotp"
//    case submit_Otp                     =  "api/submit-otp"
    case submit_Otp                     =  "api/submit-otp_new"
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
    case getSlotsByTime                 =  "api/get-slots-by-time"
    case add_address                    =  "api/add-address"
    case get_cities                     =  "api/get-cities"
    case get_emirates                   =  "api/get-emirates"
    case get_address                    =  "api/get-address"
    case get_slots                      =  "/api/get-slots"
    case book_slot                      =  "api/book-slot"
    case package_create_one_buddy       =  "api/package-create"
//    case customiseGymMembership         =  "api/membership-validity"
    case package_setdate                =  "api/package-setdate"
    case package_checkout               =  "api/package-checkout"
    case get_maember_package_group      =  "api/package-group"
    case get_buddy_member               =  "api/member-buddy-get"
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
    case join_waitlist                  =  "api/join-waitlist"
    case claim_open_spot                =  "api/claim-open-spot"
    // Free and paid classes show DIFFERENT cancellation/terms text - same
    // free/paid split every other GX booking rule already uses, just applied
    // to which doc `type` gets requested.
    case get_gx_cancellation_policy_free = "api/get-legal-document/gx_cancellation_policy_free"
    case get_gx_cancellation_policy_paid = "api/get-legal-document/gx_cancellation_policy_paid"
    case get_gx_terms_free              =  "api/get-legal-document/gx_terms_free"
    case get_gx_terms_paid              =  "api/get-legal-document/gx_terms_paid"
    case sync_device_token              =  "api/sync-device-token"
    case cancel_class_booking           =  "api/cancel-class-booking"
    case leave_waitlist                 =  "api/leave-waitlist"
//    case ccaavenue_payment              =  "api/pay"
    case ccaavenue_payment              =  "api/payment/session"
    /// Raw-HTML CCAvenue gateway page for group-class card payments — Android's
    /// `ApiURL.payamount` (`api/pay?amount=`), the exact contract
    /// `CCavenueWebCLassActivity.kt` uses today. Deliberately separate from
    /// `ccaavenue_payment` above: that endpoint is the newer JSON-wrapped
    /// contract used by subscription purchases, with no confirmed support for a
    /// class-booking `payment_for`/`schedule_id` — see Phase 8 of the migration
    /// plan for why this ports Android's raw endpoint instead of extending that one.
    case class_ccavenue_pay             =  "api/pay"
    case paymentStatus                  =  "api/payment/verify-status"
    case account_delete                 =  "api/account-delete"
//    case social_login                   =  "api/social-login"
    case social_login                   =  "api/social-login-new"
    case user_trainer                   =  "api/user-trainer"
    case user_profile                   =  "api/user-profile"
    case user_information               =  "api/user-information"
    case update_information             =  "api/update-information"
    case delete_user_profileImage       =  "api/delete-user-profile-image"
    case trainer_filter_data            =  "api/get-filter-data"
    case filter_trainer                 =  "api/get-trainers"
    case filter_gym_trainers            =  "api/gym-trainers"
    case user_health_stats              =  "api/user-health-stats"
    case user_meals                     =  "api/user-meals"
    case meal_favourite                 =  "api/meal-favourite"
    case get_trainer_time               =  "api/get-trainer-time"
    case make_favourite                 =  "api/make-favourite"
    case workout_types                  =  "api/workout-types"
    case get_workouts                   =  "api/get-workouts"
    case get_exercises                  =  "api/get-exercises"
    case body_parts                     =  "api/body-parts"
    case get_plans                      =  "api/get-plans"
    case upgrade_plan                   =  "api/upgrade-plan"
    case review_upgrade_package         =  "api/review-upgrade-package"
    case make_payment                   =  "api/make-payment"
    case trainer_review                 =  "api/trainer-review"
    case wokout_detail                  =  "api/wokout-detail"
    case workout_start                  =  "api/workout-start"
    case exercise_complete              =  "api/exercise-complete"
    case workout_complete               =  "api/workout-complete"
    case get_workout_summary            =  "api/get-workout-summary"
    case my_workouts                    =  "api/my-workouts"
    case get_user_streak                =  "api/get-user-streak"
    case trainer_remindworkouttime      =  "api/trainer/remindworkouttime"
    case createworkout                  =  "api/createworkout"
    case set_edit_workout               =  "api/set-edit-workout"
    case delete_workout_exercise        =  "api/delete-workout-exercise"
    case workout_delete                 =  "api/workout-delete"
    case edit_workout_exercise          =  "api/edit-workout-exercise"
    case getTrainerGroup                =   "api/get-trainer-group"
    case bestPlans                      =   "api/best-plans"
   case reviewPackageCheckout           =   "api/review-package-checkout"
   case homeGetContents                 =   "api/get-contents"
   case homeGetStories                  =   "api/get-stories"
   case getSubscriptionSlots            =   "api/get-subscription-slots"
   case getGroupDetail                  =   "api/get-group-detail"
   case bookAssessment                  =   "api/book-assessment"
   case reviewAssessment                =   "api/review-assessment"
   case checkAssesmentStatus            =   "api/check-assesment-status"
   case getBanners                      =   "api/get-banners"
   case getGymTrainers                  =   "api/get-gym-trainers"
   case getTrainerStudios               =   "api/get-trainer-studios"
   case clientPtTerms               =   "api/get-legal-document/client_pt_terms"
   case skipProfile               =   "api/skip-profile"
  
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
