//
//  SgptVM.swift
//  MyPT
//
//  Small Group PT (SGPT) home-carousel + See All screen.
//  Split out from UpcomingClassVM.swift rather than added there: SGPT is a
//  distinct feature/domain (own model, own endpoint) - every existing method
//  in UpcomingClassVM is specifically about the Group Classes domain
//  (UpcomingClassModel / ViewAllClassBaseModel / etc.), same one-VM-per-domain
//  split already used for HomepageViewModel/DashboardVM/TrainerVM/BookingVM.
//

import Foundation

struct SgptCreditsBaseModel: Codable {
    var status: Bool?
    var message: String?
    var data: SgptCreditsModel?
}

struct SgptCreditsModel: Codable {
    var hasCredits: Bool?
    var remainingCredits: Int?
    var totalCredits: Int?
    var usedCredits: Int?
    var expiresAt: String?
    var expiresInDays: Int?

    enum CodingKeys: String, CodingKey {
        case hasCredits = "has_credits"
        case remainingCredits = "remaining_credits"
        case totalCredits = "total_credits"
        case usedCredits = "used_credits"
        case expiresAt = "expires_at"
        case expiresInDays = "expires_in_days"
    }
}

struct SgptPacksBaseModel: Codable {
    var status: Bool?
    var data: [SgptPackModel]?
}

/// What `api/sgpt-eligibility` says the pricing screen should offer. Without
/// gym access at the club the only sellable thing is a bundle that includes it,
/// which is the same rule the server enforces at book and purchase time.
struct SgptEligibilityModel: Codable {
    var authenticated: Bool?
    var studioId: String?
    var hasGymAccess: Bool?
    var remainingCredits: Int?
    var canBuyCredits: Bool?
    var needsBundle: Bool?
    var creditsExpireOn: String?
    var membershipExpired: Bool?
    var membershipEndedOn: String?
    var membershipStudioName: String?
    var renewalSubscriptionId: FlexibleValue?
    var shouldRenew: Bool?
    var accessEndsOn: String?
    /// Days of club access left, so the pricing screen can compare it against
    /// the validity of the pack being bought without doing date maths.
    var accessDaysLeft: Int?

    enum CodingKeys: String, CodingKey {
        case authenticated
        case studioId = "studio_id"
        case hasGymAccess = "has_gym_access"
        case remainingCredits = "remaining_credits"
        case canBuyCredits = "can_buy_credits"
        case needsBundle = "needs_bundle"
        case creditsExpireOn = "credits_expire_on"
        case membershipExpired = "membership_expired"
        case membershipEndedOn = "membership_ended_on"
        case membershipStudioName = "membership_studio_name"
        case renewalSubscriptionId = "renewal_subscription_id"
        case shouldRenew = "should_renew"
        case accessEndsOn = "access_ends_on"
        case accessDaysLeft = "access_days_left"
    }
}

struct SgptEligibilityBaseModel: Codable {
    var status: Bool?
    var data: SgptEligibilityModel?
}

struct SgptSessionDetailModel: Codable {
    var description: String?
    var trainerId: FlexibleValue?
    var trainerName: String?
    var trainerImage: String?
    var trainerExperience: FlexibleValue?
    var trainerRating: FlexibleValue?
    var trainerRatingCount: Int?
    var trainerSpecialities: [String]?
    var studioId: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case description
        case trainerId = "trainer_id"
        case trainerName = "trainer_name"
        case trainerImage = "trainer_image"
        case trainerExperience = "trainer_experience"
        case trainerRating = "trainer_rating"
        case trainerRatingCount = "trainer_rating_count"
        case trainerSpecialities = "trainer_specialities"
        case studioId = "studio_id"
    }
}

struct SgptSessionDetailBaseModel: Codable {
    var status: Bool?
    var data: SgptSessionDetailModel?
}

/// One bundle (membership + credits) from `api/sgpt-bundles`.
struct SgptBundleModel: Codable {
    var id: FlexibleValue?
    var name: String?
    var description: String?
    var studioId: String?
    var price: Double?
    var listPrice: Double?
    var saving: Double?
    var credits: Int?
    var validity: Int?
    var pricePerSession: Double?
    var includesGymAccess: Bool?
    var membershipLabel: String?
    var membershipDays: Int?
    var studioName: String?
    var pillText: String?
    var sgptPlanName: String?
    var perks: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, credits, validity, saving
        case studioId = "studio_id"
        case listPrice = "list_price"
        case pricePerSession = "price_per_session"
        case includesGymAccess = "includes_gym_access"
        case membershipLabel = "membership_label"
        case membershipDays = "membership_days"
        case studioName = "studio_name"
        case pillText = "pill_text"
        case sgptPlanName = "sgpt_plan_name"
        case perks
    }
}

struct SgptBundlesBaseModel: Codable {
    var status: Bool?
    var data: [SgptBundleModel]?
}

/// One purchasable credit pack from `api/sgpt-packages`.
///
/// `isDeal` is only true while a limited-time deal is still running - the
/// server drops an expired deal back to a normal plan - so the app can trust
/// it without re-checking. `dealEndsInSeconds` is a duration rather than a
/// timestamp so the countdown never drifts with device clock skew.
struct SgptPackModel: Codable {
    var id: FlexibleValue?
    var name: String?
    var studioId: FlexibleValue?
    var credits: Int?
    var price: Double?
    var pricePerSession: Double?
    var validity: Int?
    var periodType: String?
    var specialMsg: String?
    var msg: String?
    var isDeal: Bool?
    var dealPillText: String?
    var dealEndsInSeconds: Int?
    var dealEndsAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, credits, price, validity, msg
        case studioId = "studio_id"
        case pricePerSession = "price_per_session"
        case periodType = "period_type"
        case specialMsg = "special_msg"
        case isDeal = "is_deal"
        case dealPillText = "deal_pill_text"
        case dealEndsInSeconds = "deal_ends_in_seconds"
        case dealEndsAt = "deal_ends_at"
    }
}

struct SgptBookBaseModel: Codable {
    var status: Bool?
    var msg: String?
    var errors: String?
    var data: SgptBookResultModel?
}

struct SgptBookResultModel: Codable {
    var rosterId: FlexibleValue?
    var creditsUsed: Int?
    var remainingCredits: Int?
    var remainingSeats: Int?

    enum CodingKeys: String, CodingKey {
        case rosterId = "roster_id"
        case creditsUsed = "credits_used"
        case remainingCredits = "remaining_credits"
        case remainingSeats = "remaining_seats"
    }
}

/// Result of the UAT mock purchase. The payment is faked; the credits are real.
struct SgptPurchaseResultModel: Codable {
    var subscriptionId: FlexibleValue?
    var creditsPurchased: Int?
    var remainingCredits: Int?
    var price: Double?
    var expiresInDays: Int?
    var booked: Bool?
    var bookingMessage: String?
    var remainingSeats: Int?

    enum CodingKeys: String, CodingKey {
        case price, booked
        case subscriptionId = "subscription_id"
        case creditsPurchased = "credits_purchased"
        case remainingCredits = "remaining_credits"
        case expiresInDays = "expires_in_days"
        case bookingMessage = "booking_message"
        case remainingSeats = "remaining_seats"
    }
}

struct SgptPurchaseBaseModel: Codable {
    var status: Bool?
    var msg: String?
    var errors: String?
    var data: SgptPurchaseResultModel?
}

class SgptVM {
    //MARK: ----------------------- api/sgpt-book

    /// Spends a credit on a session. The server owns the rules (capacity,
    /// double-booking, sufficient credits) and writes the credit spend and
    /// roster row in one transaction, so the caller only surfaces the result.
    /// A failure returns the server's own reason so the user sees why.
    class func sgptBookApi(sessionId: String, isShowLoader: Bool = true, completion: @escaping (_ result: SgptBookResultModel?, _ errorMessage: String?) -> Void) {
        let params: [String: Any] = ["session_id": sessionId]

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_book, method: .post, queries: nil, parameters: params, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                guard let responceData = getResponce else {
                    completion(nil, nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptBookBaseModel.self, from: responceData)
                if getResult.status == true, let data = getResult.data {
                    completion(data, nil)
                } else {
                    let reason = getResult.errors?.isEmpty == false ? getResult.errors : getResult.msg
                    completion(nil, reason)
                }
            } catch {
                print(error)
                completion(nil, nil)
            }
        })
    }

    //MARK: ----------------------- api/sgpt-purchase

    /// Buys a credit pack. In UAT the payment is mocked server-side but the
    /// credits granted are real. Passing `sessionId` books that session in the
    /// same call, which is the buy-then-book flow.
    class func sgptPurchaseApi(tierId: String,
                               credits: Int,
                               studioId: String,
                               sessionId: String?,
                               isShowLoader: Bool = true,
                               completion: @escaping (_ result: SgptPurchaseResultModel?, _ errorMessage: String?) -> Void) {
        var params: [String: Any] = ["studio_id": studioId, "credits": credits]
        if !tierId.isEmpty { params["tier_id"] = tierId }
        if let sessionId = sessionId, !sessionId.isEmpty {
            params["session_id"] = sessionId
        }

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_purchase, method: .post, queries: nil, parameters: params, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                guard let responceData = getResponce else {
                    completion(nil, nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptPurchaseBaseModel.self, from: responceData)
                if getResult.status == true, let data = getResult.data {
                    completion(data, nil)
                } else {
                    let reason = getResult.errors?.isEmpty == false ? getResult.errors : getResult.msg
                    completion(nil, reason)
                }
            } catch {
                print(error)
                completion(nil, nil)
            }
        })
    }

    //MARK: ----------------------- api/sgpt-packages

    /// Credit packs, optionally narrowed to one club's pricing.
    /// Whether this member can book at a club, and therefore whether the
    /// pricing screen should sell credits or a bundle. Token-optional server
    /// side, so a signed-out browser gets a truthful "no access".
    class func sgptEligibilityApi(studioId: String? = nil, isShowLoader: Bool = false, completion: @escaping (_ result: SgptEligibilityModel?) -> Void) {
        var queries: [String: String] = [:]
        if let studioId = studioId, !studioId.isEmpty {
            queries["studio_id"] = studioId
        }

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_eligibility, method: .get, queries: queries.isEmpty ? nil : queries, parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptEligibilityBaseModel.self, from: responceData)
                completion(getResult.data)
            } catch {
                print(error)
                completion(nil)
            }
        })
    }

    class func sgptDetailApi(sessionId: String, isShowLoader: Bool = false, completion: @escaping (_ result: SgptSessionDetailModel?) -> Void) {
        guard !sessionId.isEmpty else {
            completion(nil)
            return
        }

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_detail, method: .get, queries: ["id": sessionId], parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptSessionDetailBaseModel.self, from: responceData)
                completion(getResult.data)
            } catch {
                print(error)
                completion(nil)
            }
        })
    }

    /// Bundles (membership + credits) a club sells - what a non-member buys.
    class func sgptBundlesApi(studioId: String? = nil, isShowLoader: Bool = false, completion: @escaping (_ resultData: [SgptBundleModel]?) -> Void) {
        var queries: [String: String] = [:]
        if let studioId = studioId, !studioId.isEmpty {
            queries["studio_id"] = studioId
        }

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_bundles, method: .get, queries: queries.isEmpty ? nil : queries, parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptBundlesBaseModel.self, from: responceData)
                completion(getResult.data)
            } catch {
                print(error)
                completion(nil)
            }
        })
    }

    class func sgptPackagesApi(studioId: String? = nil, isShowLoader: Bool = false, completion: @escaping (_ resultData: [SgptPackModel]?) -> Void) {
        var queries: [String: String] = [:]
        if let studioId = studioId, !studioId.isEmpty {
            queries["studio_id"] = studioId
        }

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_packages, method: .get, queries: queries.isEmpty ? nil : queries, parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptPacksBaseModel.self, from: responceData)
                completion(getResult.data)
            } catch {
                print(error)
                completion(nil)
            }
        })
    }

    //MARK: ----------------------- api/sgpt-credits

    /// Credit balance for the signed-in member. `nil` means the balance could
    /// not be read (offline, signed out, server error) - callers treat that
    /// the same as "no credits" and fall through to the pricing screen.
    class func sgptCreditsApi(isShowLoader: Bool = false, completion: @escaping (_ resultData: SgptCreditsModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_credits, method: .get, queries: nil, parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptCreditsBaseModel.self, from: responceData)
                completion(getResult.data)
            } catch {
                print(error)
                completion(nil)
            }
        })
    }

    //MARK: ----------------------- api/sgpt-upcoming
    class func sgptUpcomingApi(inputParams: [String: String]?, isShowLoader: Bool = false, completion: @escaping (_ resultData: [SgptSessionModel]?) -> Void) {
        /*
         let params:[String:String] = [
            "lat": "", // lat: 13.887989
            "long": "" // long: 12.67788
         ]
        */

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_upcoming, method: .get, queries: inputParams, parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                print(getResponce as Any)
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptUpcomingBaseModel.self, from: responceData)
                // A present, non-empty `data` array is real sessions to show
                // regardless of `status` - don't let an unreliable/ambiguous
                // status flag hide sessions that actually came back.
                if let data = getResult.data, !data.isEmpty {
                    completion(data)
                } else {
                    completion(getResult.status == true ? [] : nil)
                }
            } catch {
                print(error)
                completion(nil)
            }
        })
    }
}
