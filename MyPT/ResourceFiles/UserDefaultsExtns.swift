//
//  UserDefaultsExtns.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import Foundation

let appUserDefaults = UserDefaults.standard

enum UserDefaultsKeys : String {
    case isLoggedIn            =  "Login"
    case isSkipToHome          =  "skip"
    case userID                =  "userId"
    case packagerCreated       =  "packageCreated"
    case accessToken           =  "accessToken"
    case refressToken          =  "refreshToken"
    case fcmToken              =  "fcmToken"
    case latLong               =  "latLong"
    case currendAddr           =  "currentAddr"
    case social_login_userId   =   "social_id"
}

extension UserDefaults{
    
    //MARK: Lat Log
    func setLatLong(value: String?){
        set(value, forKey: UserDefaultsKeys.latLong.rawValue)
        synchronize()
    }
    
    //MARK: Retrieve Lat Long
    func getLatLong() -> String?{
        return string(forKey: UserDefaultsKeys.latLong.rawValue)
    }
    
    //MARK: set Current addres
    func setCurrentAddr(value: String?){
        set(value, forKey: UserDefaultsKeys.currendAddr.rawValue)
        synchronize()
    }
    
    //MARK: Retrieve Current addres
    func getCurrentAddr() -> String?{
        return string(forKey: UserDefaultsKeys.currendAddr.rawValue)
    }
    
    //MARK: Check Login
    func setRegistrationSkip(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isSkipToHome.rawValue)
        synchronize()
    }
    
    func getRegistrationSkip()-> Bool {
        return bool(forKey: UserDefaultsKeys.isSkipToHome.rawValue)
    }
    
    //MARK: Check Login
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func getIsLoggedIn()-> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    //MARK: Save User Data
    func setUserID(value: String?){
        set(value, forKey: UserDefaultsKeys.userID.rawValue)
        synchronize()
    }
    
    //MARK: Retrieve User Data
    func getUserID() -> String?{
        return string(forKey: UserDefaultsKeys.userID.rawValue)
    }
    
    //MARK: Save social login userId
    func setSocialId(value: String?){
        set(value, forKey: UserDefaultsKeys.social_login_userId.rawValue)
        synchronize()
    }
    
    //MARK: Retrieve social login userId
    func getSocialId() -> String?{
        return string(forKey: UserDefaultsKeys.social_login_userId.rawValue)
    }
    
    func setIsPackageCreated(value: Bool) {
        set(!value, forKey: UserDefaultsKeys.packagerCreated.rawValue)
        synchronize()
    }
    
    func getIsPackageCreated()-> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    func setUserName(value: String?){
        set(value, forKey: "userName")
        synchronize()
    }
    
    func getUserName() -> String?{
        return string(forKey: "userName")
    }
    
    
    func setGymPackage(value: String?){
        set(value, forKey: "gym")
        synchronize()
    }
    
    func getGymPackage() -> String?{
        return string(forKey: "gym")
    }
    
    func saveModel<T: Codable>(_ model: T) {
        let key = String(describing: T.self) // Use the type name as the key
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(model) {
            defaults.set(encodedData, forKey: key)
        }
    }
    
    func getModel<T: Codable>(as type: T.Type) -> T? {
        let key = String(describing: T.self) // Use the type name as the key
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: key),
           let decodedModel = try? JSONDecoder().decode(T.self, from: data) {
            return decodedModel
        }
        return nil
    }
    
    /*
     // Save model to UserDefaults (no need to pass a key)
     saveModel(user)
     
     // Retrieve model from UserDefaults
     if let retrievedUser: UserModel = getModel(as: UserModel.self) {
     print("User ID: \(retrievedUser.id), Name: \(retrievedUser.name)")
     }
     */
    
    func saveUserToUserDefaults<T: Codable>(_ user: T) {
        let key = String(describing: T.self) // Use the type name as the key
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(user) {
            defaults.set(encodedData, forKey: key)
        }
    }
    
    func getUserFromUserDefaults<T: Codable>(as user: T.Type) -> T? {
        let key = String(describing: T.self) // Use the type name as the key
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: key),
           let decodedModel = try? JSONDecoder().decode(T.self, from: data) {
            return decodedModel
        }
        return nil
    }
    
    //setAccessToken
    func setAccessToken(accessToken: String?){
        set(accessToken, forKey: UserDefaultsKeys.accessToken.rawValue)
        synchronize()
    }
    
    func getAccessToken() -> String?{
        return string(forKey: UserDefaultsKeys.accessToken.rawValue)
    }
    
    //    func getAccn() -> Int?{
    //        return integer(forKey: UserDefaultsKeys.accessToken.rawValue)
    //    }
    
    //setRefreshToken
    func setRefreshToken(refreshToken: String?){
        set(refreshToken, forKey: UserDefaultsKeys.refressToken.rawValue)
        synchronize()
    }
    
    func getRefreshToken() -> String?{
        return string(forKey: UserDefaultsKeys.refressToken.rawValue)
    }
    
    //setRefreshToken
    func setFCMToken(refreshToken: String?){
        set(refreshToken, forKey: UserDefaultsKeys.fcmToken.rawValue)
        synchronize()
    }
    
    func getReFCMToken() -> String?{
        return string(forKey: UserDefaultsKeys.fcmToken.rawValue)
    }
    
    
    //MARK: ----------- TO CLEAR ALL DATA
    func clearUserDefault() -> Bool {
        guard let domainName = Bundle.main.bundleIdentifier else {
            return false
        }
        removePersistentDomain(forName: domainName)
        synchronize()
        print("All Remove Data",Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
        return true
    }
    
    //------------Remove value
    func removeValue(forKey key: String) {
        self.removeObject(forKey: key)
    }
}
