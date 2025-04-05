//
//  UserDefaultsExtns.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import Foundation

let appUserDefaults = UserDefaults.standard

enum UserDefaultsKeys : String {
    case isLoggedIn = "Login"
    case userID     = "userId"
    case packagerCreated = "packageCreated"
    case accessToken = "accessToken"
    case refressToken = "refreshToken"
}

extension UserDefaults{
    
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
}
